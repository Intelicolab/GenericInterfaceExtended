# --
# Copyright (C) 2026 INTELICOLAB
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::GenericInterface::Operation::Change::ChangeSearch;

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
        ErrorCode    => 'ChangeSearch.AuthFail',
        ErrorMessage => 'ChangeSearch: Could not authenticate.',
    ) if !$UserID;

    # ITSMChangeManagement is a soft dependency.
    my $ChangeObject;
    eval {
        $ChangeObject = $Kernel::OM->Get('Kernel::System::ITSMChange');
    };
    if ($@) {
        return $Self->ReturnError(
            ErrorCode    => 'ChangeSearch.ModuleNotAvailable',
            ErrorMessage => 'ChangeSearch: ITSMChangeManagement module is not installed.',
        );
    }

    # Build search params.
    my %SearchParams = (
        UserID => $UserID,
    );

    # Scalar params — only include if provided.
    for my $ScalarParam (qw(ChangeNumber ChangeTitle Description Justification Limit)) {
        if ( defined $Param{Data}{$ScalarParam} && $Param{Data}{$ScalarParam} ne '' ) {
            $SearchParams{$ScalarParam} = $Param{Data}{$ScalarParam};
        }
    }

    # Array params — normalize scalar to arrayref.
    for my $ArrayParam (qw(
        ChangeStateIDs ChangeStates ChangeManagerIDs ChangeBuilderIDs
        CategoryIDs ImpactIDs PriorityIDs CABAgents CABCustomers
        OrderBy OrderByDirection
    )) {
        if ( defined $Param{Data}{$ArrayParam} ) {
            my $Value = $Param{Data}{$ArrayParam};
            $Value = [$Value] if !IsArrayRefWithData($Value);
            $SearchParams{$ArrayParam} = $Value if IsArrayRefWithData($Value);
        }
    }

    # Date range params — pass through as scalars (format: YYYY-MM-DD HH:MM:SS).
    for my $DateParam (qw(
        PlannedStartTimeNewerDate PlannedStartTimeOlderDate
        PlannedEndTimeNewerDate   PlannedEndTimeOlderDate
        ActualStartTimeNewerDate  ActualStartTimeOlderDate
        ActualEndTimeNewerDate    ActualEndTimeOlderDate
        CreateTimeNewerDate       CreateTimeOlderDate
        ChangeTimeNewerDate       ChangeTimeOlderDate
        RequestedTimeNewerDate    RequestedTimeOlderDate
    )) {
        if ( defined $Param{Data}{$DateParam} && $Param{Data}{$DateParam} ne '' ) {
            $SearchParams{$DateParam} = $Param{Data}{$DateParam};
        }
    }

    # Result type: 'ARRAY' (default) or 'COUNT'.
    if ( defined $Param{Data}{Result} && $Param{Data}{Result} eq 'COUNT' ) {
        $SearchParams{Result} = 'COUNT';
    }

    my $Result = $ChangeObject->ChangeSearch(%SearchParams);

    # COUNT mode returns a scalar.
    if ( defined $SearchParams{Result} && $SearchParams{Result} eq 'COUNT' ) {
        return {
            Success => 1,
            Data    => {
                Count => $Result,
            },
        };
    }

    my @ChangeIDs = @{ $Result || [] };

    return {
        Success => 1,
        Data    => {
            ChangeIDs => \@ChangeIDs,
        },
    };
}

1;
