import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;
  bool isConnected = false;
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  /* Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit'),
            actions: <Widget>[
              InkWell(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Text("YES"),
                ),
              ),
            ],
          ),
        ) ??
        false;
  } */

  @override
  void initState() {
    super.initState();
    WebView.platform = SurfaceAndroidWebView();
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      print(result);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        setState(() {
          isConnected = true;
        });
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  WebViewController webView;

  Future<bool> _onBack() async {
    bool goBack;
    var value = await webView.canGoBack(); // check webview can go back
    if (value) {
      webView.goBack(); // perform webview back operation
      return false;
    } else {
      await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: const Text('Are you sure?',
              style: TextStyle(color: Colors.purple)),
          content: const Text('Do you want exit'),
          actions: <Widget>[
            InkWell(
              onTap: () => Navigator.of(context).pop(false),
              child: Text("NO"),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  print("pressed yes");
                  SystemNavigator.pop();
                  setState(() {
                    goBack = true;
                  });
                },
                child: Text("YES"),
              ),
            ),
          ],
        ),
      );
      return goBack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBack,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: isConnected
              ? Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: WebView(
                        onWebResourceError: (error) {
                          return Center(
                              child: const Text(
                            "Error while loading page",
                            style: TextStyle(fontSize: 22),
                          ));
                        },
                        javascriptMode: JavascriptMode.unrestricted,
                        // initialUrl: "https://puretransportation.netlify.app/",
                        initialUrl: "http://13.59.255.15/",
                        // initialUrl: "https://google.com",
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          webView = webViewController;
                          _controller.complete(webViewController);
                        },
                        onPageFinished: (_) {
                          setState(() {
                            isLoading = false;
                          });
                        },
                      ),
                    ),
                    if (isLoading) LoadingPageWidget(),
                  ],
                )
              : NoInternetConnectionWidget(),
        ),
      ),
    );
  }
}

class LoadingPageWidget extends StatelessWidget {
  const LoadingPageWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Center(
          child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Image.asset(
          "assets/images/ptLogo.png",
        ),
      )),
    );
  }
}

class NoInternetConnectionWidget extends StatelessWidget {
  const NoInternetConnectionWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 55,
          ),
          const SizedBox(height: 10),
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: const Text(
              "No internet connection\nPlease make sure you are\nconnected to internet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21),
            ),
          ),
        ],
      ),
    );
  }
}
