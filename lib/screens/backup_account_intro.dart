// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tech_wallet/common/fw_design.dart';
// import 'package:flutter_tech_wallet/common/widgets/button.dart';
// import 'package:flutter_tech_wallet/screens/prepare_recovery_phrase_intro.dart';
//
// class BackupAccountIntro extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0.0,
//           leading: IconButton(
//             icon: FwIcon(
//               FwIcons.back,
//               size: 24,
//               color: Color(0xFF3D4151),
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: Container(
//             color: Colors.white,
//             child: Padding(
//                 padding: EdgeInsets.only(top: 40),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           height: 158,
//                           width: 158,
//                           decoration: BoxDecoration(
//                               color: Color(0xFF9196AA),
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(79))),
//                         )
//                       ],
//                     ),
//                     SizedBox(
//                       height: 48,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 20, right: 20),
//                       child: FwText(
//                         'Back up your account using a recovery passphrase',
//                         style: FwTextStyle.extraLarge,
//                         textAlign: TextAlign.center,
//                         color: FwColor.globalNeutral550,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 20, right: 20),
//                       child: FwText(
//                         'Without your recovery passphrase, if you lose your device or delete the app, you will permanently lose access your account.',
//                         style: FwTextStyle.m,
//                         textAlign: TextAlign.center,
//                         color: FwColor.globalNeutral550,
//                       ),
//                     ),
//                     Expanded(child: Container()),
//                     Padding(
//                         padding: EdgeInsets.only(left: 20, right: 20),
//                         child: FwButton(
//                             child: FwText(
//                               'I understand',
//                               style: FwTextStyle.mBold,
//                               color: FwColor.white,
//                             ),
//                             onPressed: () {
//                               Navigator.push(context,
//                                   PrepareRecoveryPhraseIntro().route());
//                             })),
//                     SizedBox(
//                       height: 40,
//                     )
//                   ],
//                 ))));
//   }
// }
