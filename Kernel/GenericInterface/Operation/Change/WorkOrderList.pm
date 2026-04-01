# --
# Copyright (C) 2026 INTELICOLAB
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::GenericInterface::Operation::Change::WorkOrderList;

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
        ErrorCode    => 'WorkOrderList.AuthFail',
        ErrorMessage => 'WorkOrderList: Could not authenticate.',
    ) if !$UserID;

    # ITSMChangeManagement is a soft dependency.
    my $WorkOrderObject;
    eval {
        $WorkOrderObject = $Kernel::OM->Get('Kernel::System::ITSMChange::ITSMWorkOrder');
    };
    if ($@) {
        return $Self->ReturnError(
            ErrorCode    => 'WorkOrderList.ModuleNotAvailable',
            ErrorMessage => 'WorkOrderList: ITSMChangeManagement module is not installed.',
        );
    }

    my $ChangeID = $Param{Data}{ChangeID};

    return $Self->ReturnError(
        ErrorCode    => 'WorkOrderList.MissingParameter',
        ErrorMessage => 'WorkOrderList: ChangeID is required.',
    ) if !$ChangeID;

    my $WorkOrderIDsRef = $WorkOrderObject->WorkOrderList(
        ChangeID => $ChangeID,
        UserID   => $UserID,
    );

    my @WorkOrderIDs = @{ $WorkOrderIDsRef || [] };

    return {
        Success => 1,
        Data    => {
            WorkOrderIDs => \@WorkOrderIDs,
        },
    };
}

1;
