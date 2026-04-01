# --
# Copyright (C) 2026 INTELICOLAB
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::GenericInterface::Operation::Change::ChangeList;

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
        ErrorCode    => 'ChangeList.AuthFail',
        ErrorMessage => 'ChangeList: Could not authenticate.',
    ) if !$UserID;

    # ITSMChangeManagement is a soft dependency.
    my $ChangeObject;
    eval {
        $ChangeObject = $Kernel::OM->Get('Kernel::System::ITSMChange');
    };
    if ($@) {
        return $Self->ReturnError(
            ErrorCode    => 'ChangeList.ModuleNotAvailable',
            ErrorMessage => 'ChangeList: ITSMChangeManagement module is not installed.',
        );
    }

    my $ChangeIDsRef = $ChangeObject->ChangeList(
        UserID => $UserID,
    );

    my @ChangeIDs = @{ $ChangeIDsRef || [] };

    return {
        Success => 1,
        Data    => {
            ChangeIDs => \@ChangeIDs,
        },
    };
}

1;
