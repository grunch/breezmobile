import 'dart:async';

import 'package:breez/bloc/account/account_bloc.dart';
import 'package:breez/bloc/account/account_model.dart';
import 'package:breez/bloc/account/add_funds_bloc.dart';
import 'package:breez/bloc/blocs_provider.dart';
import 'package:breez/bloc/user_profile/breez_user_model.dart';
import 'package:breez/routes/user/add_funds/address_widget.dart';
import 'package:breez/theme_data.dart' as theme;
import 'package:breez/widgets/back_button.dart' as backBtn;
import 'package:breez/widgets/single_button_bottom_bar.dart';
import 'package:flutter/material.dart';

class DepositToBTCAddressPage extends StatefulWidget {
  final BreezUserModel _user;
  final AccountBloc _accountBloc;

  const DepositToBTCAddressPage(this._user, this._accountBloc);

  @override
  State<StatefulWidget> createState() {
    return new DepositToBTCAddressPageState();
  }
}

class DepositToBTCAddressPageState extends State<DepositToBTCAddressPage> {
  final String _title = "Deposit To Bitcoin Address";
  AddFundsBloc _addFundsBloc;
  StreamSubscription<AccountModel> _accountSubscription;

  @override
  initState() {
    super.initState();
    _addFundsBloc = new AddFundsBloc(widget._user.userID);
    _accountSubscription = widget._accountBloc.accountStream.listen((acc) {
      if (!acc.bootstraping) {
        _addFundsBloc.addFundRequestSink.add(null);
        _accountSubscription.cancel();
      }
    });
  }

  @override
  void dispose() {
    _addFundsBloc.addFundRequestSink.close();
    _accountSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = AppBlocsProvider.of<AccountBloc>(context);
    return new StreamBuilder(
        stream: accountBloc.accountStream,
        builder: (BuildContext context, AsyncSnapshot<AccountModel> accSnapshot) {
          return StreamBuilder(
              stream: _addFundsBloc.addFundResponseStream,
              builder: (BuildContext context, AsyncSnapshot<AddFundResponse> snapshot) {
                return Material(
                  child: new Scaffold(
                      appBar: new AppBar(
                        iconTheme: theme.appBarIconTheme,
                        textTheme: theme.appBarTextTheme,
                        backgroundColor: theme.BreezColors.blue[500],
                        leading: backBtn.BackButton(),
                        title: new Text(
                          _title,
                          style: theme.appBarTextStyle,
                        ),
                        elevation: 0.0,
                      ),
                      body: new Container(
                        child: Material(
                            child: getBody(
                                context,
                                accSnapshot.data,
                                snapshot.data,
                                snapshot.hasError
                                    ? "Failed to retrieve an address from Breez server\nPlease check your internet connection."
                                    : null)),
                      )),
                );
              });
        });
  }

  Widget getBody(BuildContext context, AccountModel account, AddFundResponse response, String error) {
    return Column(children: <Widget>[
      AddressWidget(response?.address, response?.backupJson),
      response == null
          ? SizedBox()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), border: Border.all(color: theme.errorColor)),
                padding: new EdgeInsets.all(16),
                child: Text(
                  "Send up to " + account.currency.format(response.maxAllowedDeposit, includeSymbol: true) + " to this address.",
                  style: theme.reserveAmountWarningStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
      Expanded(child: SizedBox()),
      _buildBottomBar(response, account, hasError: error != null ? true : false),
    ]);
  }

  Widget _buildBottomBar(AddFundResponse response, AccountModel account, {hasError = false}) {
    if (hasError || response?.errorMessage?.isNotEmpty == true) {
      return SingleButtonBottomBar(
          text: hasError ? "RETRY" : "CLOSE",
          onPressed: () {
            if (hasError) {
              _addFundsBloc.addFundRequestSink.add(null);
            } else {
              Navigator.of(context).pop();
            }
          });
    }

    return SizedBox();
  }
}