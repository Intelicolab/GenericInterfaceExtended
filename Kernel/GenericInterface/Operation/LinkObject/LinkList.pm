# --
# Copyright (C) 2026 INTELICOLAB
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::GenericInterface::Operation::LinkObject::LinkList;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use parent qw(Kernel::GenericInterface::Operation::Common);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    for my $Needed (qw(DebuggerObject WebserviceID)) {
        if ( !$Param{$Needed} ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Needed!",
            };
        }
        $Self->{$Needed} = $Param{$Needed};
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my ( $UserID, $UserType ) = $Self->Auth(%Param);

    return $Self->ReturnError(
        ErrorCode    => 'LinkList.AuthFail',
        ErrorMessage => 'LinkList: Could not authenticate.',
    ) if !$UserID;

    # Validate required params.
    my $Object = $Param{Data}{Object};
    my $Key    = $Param{Data}{Key};

    return $Self->ReturnError(
        ErrorCode    => 'LinkList.MissingParameter',
        ErrorMessage => 'LinkList: Object is required.',
    ) if !$Object;

    return $Self->ReturnError(
        ErrorCode    => 'LinkList.MissingParameter',
        ErrorMessage => 'LinkList: Key is required.',
    ) if !$Key;

    # Build LinkList params.
    my %LinkListParams = (
        Object => $Object,
        Key    => $Key,
        State  => $Param{Data}{State}     || 'Valid',
        UserID => $UserID,
    );

    if ( defined $Param{Data}{Object2} && $Param{Data}{Object2} ne '' ) {
        $LinkListParams{Object2} = $Param{Data}{Object2};
    }

    if ( defined $Param{Data}{Direction} && $Param{Data}{Direction} ne '' ) {
        $LinkListParams{Direction} = $Param{Data}{Direction};
    }
    else {
        $LinkListParams{Direction} = 'Both';
    }

    if ( defined $Param{Data}{Type} && $Param{Data}{Type} ne '' ) {
        $LinkListParams{Type} = $Param{Data}{Type};
    }

    my $LinkListRef = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkList(
        %LinkListParams,
    );

    # LinkList may return a hashref or a hash depending on context.
    my %LinkList;
    if ( ref $LinkListRef eq 'HASH' ) {
        %LinkList = %{$LinkListRef};
    }

    # Flatten the nested hash structure for JSON serialization.
    # LinkList returns: {ObjectType}{LinkType}{Direction}{ID} = 1
    # Convert to a list of link entries for clean JSON output.
    my @Links;
    for my $ObjectType ( sort keys %LinkList ) {
        next if ref $LinkList{$ObjectType} ne 'HASH';
        for my $LinkType ( sort keys %{ $LinkList{$ObjectType} } ) {
            next if ref $LinkList{$ObjectType}{$LinkType} ne 'HASH';
            for my $Direction ( sort keys %{ $LinkList{$ObjectType}{$LinkType} } ) {
                next if ref $LinkList{$ObjectType}{$LinkType}{$Direction} ne 'HASH';
                for my $ObjectKey ( sort keys %{ $LinkList{$ObjectType}{$LinkType}{$Direction} } ) {
                    push @Links, {
                        Object    => $ObjectType,
                        Type      => $LinkType,
                        Direction => $Direction,
                        Key       => $ObjectKey,
                    };
                }
            }
        }
    }

    return {
        Success => 1,
        Data    => {
            LinkList => \@Links,
        },
    };
}

1;
