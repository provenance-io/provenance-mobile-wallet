// import 'package:provenance_wallet/common/pw_design.dart';
// import 'package:provenance_wallet/common/widgets/pw_app_bar.dart';
// import 'package:provenance_wallet/screens/account_button.dart';
// import 'package:provenance_wallet/screens/add_account_origin.dart';
// import 'package:provenance_wallet/screens/add_basic_account_flow.dart';
// import 'package:provenance_wallet/util/strings.dart';

// class AccountAddBasicOptionScreen extends StatelessWidget {
//   const AccountAddBasicOptionScreen({
//     Key? key,
//   }) : super(key: key);

//   static final keyCreateAccountButton =
//       ValueKey('$AccountAddBasicOptionScreen.create_account_button');
//   static final keyRecoverAccountButton =
//       ValueKey('$AccountAddBasicOptionScreen.recover_account_button');

//   @override
//   Widget build(BuildContext context) {
//     final strings = Strings.of(context);

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: PwAppBar(
//         title: strings.accountTypeTitle,
//         leadingIcon: PwIcons.back,
//       ),
//       backgroundColor: Theme.of(context).colorScheme.neutral750,
//       body: Container(
//         color: Theme.of(context).colorScheme.neutral750,
//         child: CustomScrollView(
//           slivers: [
//             SliverFillRemaining(
//               hasScrollBody: false,
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: Spacing.large,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     VerticalSpacer.largeX3(),
//                     AccountButton(
//                       key: keyCreateAccountButton,
//                       name: strings.accountOptionCreateName,
//                       desc: strings.accountOptionCreateDesc,
//                       onPressed: () async {
//                         await Navigator.of(context).push(
//                           CreateBasicAccountFlow(
//                             origin: AddAccountOrigin.accounts,
//                           ).route(),
//                         );

//                         Navigator.of(context).pop();
//                       },
//                     ),
//                     VerticalSpacer.large(),
//                     AccountButton(
//                       key: keyRecoverAccountButton,
//                       name: strings.accountOptionRecoverName,
//                       desc: strings.accountOptionRecoverDesc,
//                       onPressed: () async {
//                         await Navigator.of(context).push(
//                           ImportBasicAccountFlow().route(),
//                         );

//                         Navigator.of(context).pop();
//                       },
//                     ),
//                     VerticalSpacer.largeX3(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
