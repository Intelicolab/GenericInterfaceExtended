# --
# Copyright (C) 2026 INTELICOLAB
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::GenericInterface::Operation::Change::WorkOrderGet;

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
        ErrorCode    => 'WorkOrderGet.AuthFail',
        ErrorMessage => 'WorkOrderGet: Could not authenticate.',
    ) if !$UserID;

    # ITSMChangeManagement is a soft dependency.
    my $WorkOrderObject;
    eval {
        $WorkOrderObject = $Kernel::OM->Get('Kernel::System::ITSMChange::ITSMWorkOrder');
    };
    if ($@) {
        return $Self->ReturnError(
            ErrorCode    => 'WorkOrderGet.ModuleNotAvailable',
            ErrorMessage => 'WorkOrderGet: ITSMChangeManagement module is not installed.',
        );
    }

    my $WorkOrderID = $Param{Data}{WorkOrderID};

    return $Self->ReturnError(
        ErrorCode    => 'WorkOrderGet.MissingParameter',
        ErrorMessage => 'WorkOrderGet: WorkOrderID is required.',
    ) if !$WorkOrderID;

    my %WorkOrderData = $WorkOrderObject->WorkOrderGet(
        WorkOrderID => $WorkOrderID,
        UserID      => $UserID,
    );

    return $Self->ReturnError(
        ErrorCode    => 'WorkOrderGet.NotFound',
        ErrorMessage => "WorkOrderGet: WorkOrder with ID $WorkOrderID not found.",
    ) if !%WorkOrderData || !$WorkOrderData{WorkOrderID};

    return {
        Success => 1,
        Data    => {
            WorkOrder => \%WorkOrderData,
        },
    };
}

1;
