import 'package:provenance_wallet/common/pw_design.dart';
import 'package:provenance_wallet/util/strings.dart';

String errorMessage(BuildContext context, String? codespace, int? code) {
  final strings = Strings.of(context);
  final unknown = strings.transactionErrorUnknown;
  if (codespace == null || code == null) {
    return unknown;
  }
  switch (codespace) {
    case "authz":
      if (code == 3) {
        return strings.transactionErrorAuthz3;
      } else {
        return unknown;
      }
    case "bank":
      switch (code) {
        case 2:
          return strings.transactionErrorBank2;
        case 3:
          return strings.transactionErrorBank3;
        case 4:
          return strings.transactionErrorBank4;
        case 5:
          return strings.transactionErrorBank5;
        case 6:
          return strings.transactionErrorBank6;
        case 7:
          return strings.transactionErrorBank7;
        default:
          return unknown;
      }
    case "capability":
      switch (code) {
        case 2:
          return strings.transactionErrorCapability2;
        case 3:
          return strings.transactionErrorCapability3;
        case 4:
          return strings.transactionErrorCapability4;
        case 5:
          return strings.transactionErrorCapability5;
        case 6:
          return strings.transactionErrorCapability6;
        case 7:
          return strings.transactionErrorCapability7;
        case 8:
          return strings.transactionErrorCapability8;
        default:
          return unknown;
      }
    case "crisis":
      switch (code) {
        case 2:
          return strings.transactionErrorCrisis2;
        default:
          return unknown;
      }
    case "distribution":
      switch (code) {
        case 2:
          return strings.transactionErrorDistribution2;
        case 3:
          return strings.transactionErrorDistribution3;
        case 4:
          return strings.transactionErrorDistribution4;
        case 5:
          return strings.transactionErrorDistribution5;
        case 6:
          return strings.transactionErrorDistribution6;
        case 7:
          return strings.transactionErrorDistribution7;
        case 8:
          return strings.transactionErrorDistribution8;
        case 9:
          return strings.transactionErrorDistribution9;
        case 10:
          return strings.transactionErrorDistribution10;
        case 11:
          return strings.transactionErrorDistribution11;
        case 12:
          return strings.transactionErrorDistribution12;
        case 13:
          return strings.transactionErrorDistribution13;
        default:
          return unknown;
      }
    case "evidence":
      switch (code) {
        case 2:
          return strings.transactionErrorEvidence2;
        case 3:
          return strings.transactionErrorEvidence3;
        case 4:
          return strings.transactionErrorEvidence4;
        case 5:
          return strings.transactionErrorEvidence5;
        default:
          return unknown;
      }
    case "feegrant":
      switch (code) {
        case 2:
          return strings.transactionErrorFeegrant2;
        case 3:
          return strings.transactionErrorFeegrant3;
        case 4:
          return strings.transactionErrorFeegrant4;
        case 5:
          return strings.transactionErrorFeegrant5;
        case 6:
          return strings.transactionErrorFeegrant6;
        case 7:
          return strings.transactionErrorFeegrant7;
        default:
          return unknown;
      }
    case "gov":
      switch (code) {
        case 2:
          return strings.transactionErrorGov2;
        case 3:
          return strings.transactionErrorGov3;
        case 4:
          return strings.transactionErrorGov4;
        case 5:
          return strings.transactionErrorGov5;
        case 6:
          return strings.transactionErrorGov6;
        case 7:
          return strings.transactionErrorGov7;
        case 8:
          return strings.transactionErrorGov8;
        case 9:
          return strings.transactionErrorGov9;
        default:
          return unknown;
      }
    case "marker":
      switch (code) {
        case 2:
          return strings.transactionErrorMarker2;
        case 3:
          return strings.transactionErrorMarker3;
        case 4:
          return strings.transactionErrorMarker4;
        case 5:
          return strings.transactionErrorMarker5;
        case 6:
          return strings.transactionErrorMarker6;
        case 7:
          return strings.transactionErrorMarker7;
        default:
          return unknown;
      }
    case "metadata":
      switch (code) {
        case 2:
          return strings.transactionErrorMetadata2;
        case 3:
          return strings.transactionErrorMetadata3;
        case 4:
          return strings.transactionErrorMetadata4;
        case 5:
          return strings.transactionErrorMetadata5;
        case 6:
          return strings.transactionErrorMetadata6;
        case 7:
          return strings.transactionErrorMetadata7;
        default:
          return unknown;
      }
    case "msgfees":
      switch (code) {
        case 2:
          return strings.transactionErrorMsgfees2;
        case 3:
          return strings.transactionErrorMsgfees3;
        case 4:
          return strings.transactionErrorMsgfees4;
        case 5:
          return strings.transactionErrorMsgfees5;
        case 6:
          return strings.transactionErrorMsgfees6;
        default:
          return unknown;
      }
    case "name":
      switch (code) {
        case 2:
          return strings.transactionErrorName2;
        case 3:
          return strings.transactionErrorName3;
        case 4:
          return strings.transactionErrorName4;
        case 5:
          return strings.transactionErrorName5;
        case 6:
          return strings.transactionErrorName6;
        case 7:
          return strings.transactionErrorName7;
        case 8:
          return strings.transactionErrorName8;
        case 9:
          return strings.transactionErrorName9;
        default:
          return unknown;
      }
    case "params":
      switch (code) {
        case 2:
          return strings.transactionErrorParams2;
        case 3:
          return strings.transactionErrorParams3;
        case 4:
          return strings.transactionErrorParams4;
        case 5:
          return strings.transactionErrorParams5;
        case 6:
          return strings.transactionErrorParams6;
        case 7:
          return strings.transactionErrorParams7;
        default:
          return unknown;
      }
    case "sdk":
      switch (code) {
        case 2:
          return strings.transactionErrorSdk2;
        case 3:
          return strings.transactionErrorSdk3;
        case 4:
          return strings.transactionErrorSdk4;
        case 5:
          return strings.transactionErrorSdk5;
        case 6:
          return strings.transactionErrorSdk6;
        case 7:
          return strings.transactionErrorSdk7;
        case 8:
          return strings.transactionErrorSdk8;
        case 9:
          return strings.transactionErrorSdk9;
        case 10:
          return strings.transactionErrorSdk10;
        case 11:
          return strings.transactionErrorSdk11;
        case 12:
          return strings.transactionErrorSdk12;
        case 13:
          return strings.transactionErrorSdk13;
        case 14:
          return strings.transactionErrorSdk14;
        case 15:
          return strings.transactionErrorSdk15;
        case 16:
          return strings.transactionErrorSdk16;
        case 17:
          return strings.transactionErrorSdk17;
        case 18:
          return strings.transactionErrorSdk18;
        case 19:
          return strings.transactionErrorSdk19;
        case 20:
          return strings.transactionErrorSdk20;
        case 21:
          return strings.transactionErrorSdk21;
        case 22:
          return strings.transactionErrorSdk22;
        case 23:
          return strings.transactionErrorSdk23;
        case 24:
          return strings.transactionErrorSdk24;
        case 25:
          return strings.transactionErrorSdk25;
        case 26:
          return strings.transactionErrorSdk26;
        case 27:
          return strings.transactionErrorSdk27;
        case 28:
          return strings.transactionErrorSdk28;
        case 29:
          return strings.transactionErrorSdk29;
        case 30:
          return strings.transactionErrorSdk30;
        case 31:
          return strings.transactionErrorSdk31;
        case 32:
          return strings.transactionErrorSdk32;
        case 33:
          return strings.transactionErrorSdk33;
        case 34:
          return strings.transactionErrorSdk34;
        case 35:
          return strings.transactionErrorSdk35;
        case 36:
          return strings.transactionErrorSdk36;
        case 37:
          return strings.transactionErrorSdk37;
        case 38:
          return strings.transactionErrorSdk38;
        case 39:
          return strings.transactionErrorSdk39;
        case 40:
          return strings.transactionErrorSdk40;
        case 41:
          return strings.transactionErrorSdk41;
        default:
          return unknown;
      }
    case "slashing":
      switch (code) {
        case 2:
          return strings.transactionErrorSlashing2;
        case 3:
          return strings.transactionErrorSlashing3;
        case 4:
          return strings.transactionErrorSlashing4;
        case 5:
          return strings.transactionErrorSlashing5;
        case 6:
          return strings.transactionErrorSlashing6;
        case 7:
          return strings.transactionErrorSlashing7;
        case 8:
          return strings.transactionErrorSlashing8;
        default:
          return unknown;
      }
    case "staking":
      switch (code) {
        case 2:
          return strings.transactionErrorStaking2;
        case 3:
          return strings.transactionErrorStaking3;
        case 4:
          return strings.transactionErrorStaking4;
        case 5:
          return strings.transactionErrorStaking5;
        case 6:
          return strings.transactionErrorStaking6;
        case 7:
          return strings.transactionErrorStaking7;
        case 8:
          return strings.transactionErrorStaking8;
        case 9:
          return strings.transactionErrorStaking9;
        case 10:
          return strings.transactionErrorStaking10;
        case 11:
          return strings.transactionErrorStaking11;
        case 12:
          return strings.transactionErrorStaking12;
        case 13:
          return strings.transactionErrorStaking13;
        case 14:
          return strings.transactionErrorStaking14;
        case 15:
          return strings.transactionErrorStaking15;
        case 16:
          return strings.transactionErrorStaking16;
        case 17:
          return strings.transactionErrorStaking17;
        case 18:
          return strings.transactionErrorStaking18;
        case 19:
          return strings.transactionErrorStaking19;
        case 20:
          return strings.transactionErrorStaking20;
        case 21:
          return strings.transactionErrorStaking21;
        case 22:
          return strings.transactionErrorStaking22;
        case 23:
          return strings.transactionErrorStaking23;
        case 24:
          return strings.transactionErrorStaking24;
        case 25:
          return strings.transactionErrorStaking25;
        case 26:
          return strings.transactionErrorStaking26;
        case 27:
          return strings.transactionErrorStaking27;
        case 28:
          return strings.transactionErrorStaking28;
        case 29:
          return strings.transactionErrorStaking29;
        case 30:
          return strings.transactionErrorStaking30;
        case 31:
          return strings.transactionErrorStaking31;
        case 32:
          return strings.transactionErrorStaking32;
        case 33:
          return strings.transactionErrorStaking33;
        case 34:
          return strings.transactionErrorStaking34;
        case 35:
          return strings.transactionErrorStaking35;
        case 36:
          return strings.transactionErrorStaking36;
        case 37:
          return strings.transactionErrorStaking37;
        case 38:
          return strings.transactionErrorStaking38;
        case 39:
          return strings.transactionErrorStaking39;
        default:
          return unknown;
      }
    case "wasm":
      switch (code) {
        case 2:
          return strings.transactionErrorWasm2;
        case 3:
          return strings.transactionErrorWasm3;
        case 4:
          return strings.transactionErrorWasm4;
        case 5:
          return strings.transactionErrorWasm5;
        case 6:
          return strings.transactionErrorWasm6;
        case 7:
          return strings.transactionErrorWasm7;
        case 8:
          return strings.transactionErrorWasm8;
        case 9:
          return strings.transactionErrorWasm9;
        case 10:
          return strings.transactionErrorWasm10;
        case 11:
          return strings.transactionErrorWasm11;
        case 12:
          return strings.transactionErrorWasm12;
        case 13:
          return strings.transactionErrorWasm13;
        case 14:
          return strings.transactionErrorWasm14;
        case 15:
          return strings.transactionErrorWasm15;
        case 16:
          return strings.transactionErrorWasm16;
        case 17:
          return strings.transactionErrorWasm17;
        case 18:
          return strings.transactionErrorWasm18;
        case 19:
          return strings.transactionErrorWasm19;
        case 20:
          return strings.transactionErrorWasm20;
        case 21:
          return strings.transactionErrorWasm21;
        case 22:
          return strings.transactionErrorWasm22;
        default:
          return unknown;
      }
    default:
      return unknown;
  }
}
