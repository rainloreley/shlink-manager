import 'package:flutter/material.dart';
import 'package:shlink_app/API/ServerManager.dart';
import 'package:shlink_app/main.dart';
import 'globals.dart' as globals;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _server_url_controller;
  late TextEditingController _apikey_controller;

  bool _isLoggingIn = false;
  String _errorMessage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _server_url_controller = TextEditingController();
    _apikey_controller = TextEditingController();
  }

  void _connect() async {
    setState(() {
      _isLoggingIn = true;
      _errorMessage = "";
    });
    final connectResult = await globals.serverManager.initAndConnect(_server_url_controller.text, _apikey_controller.text);
    connectResult.fold((l) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InitialPage())
      );
      setState(() {
        _isLoggingIn = false;
      });
    }, (r) {
      if (r is ApiFailure) {
        setState(() {
          _errorMessage = r.detail;
          _isLoggingIn = false;
        });
      }
      else if (r is RequestFailure) {
        setState(() {
          _errorMessage = r.description;
          _isLoggingIn = false;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
              title: const Text("Add server")
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(bottom: 8),
                      child: Text("Server URL", style: TextStyle(fontWeight: FontWeight.bold),)),
                  TextField(
                    controller: _server_url_controller,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "https://shlink.example.com"
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text("API Key", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextField(
                    controller: _apikey_controller,
                    keyboardType: TextInputType.text,
                      obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "..."
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => {
                            _connect()
                          },
                          child: _isLoggingIn ? Container(
                            width: 34,
                            height: 34,
                            padding: const EdgeInsets.all(4),
                            child: const CircularProgressIndicator(),
                          ) : const Text("Connect", style: TextStyle(fontSize: 20)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text(_errorMessage, style: TextStyle(color: Colors.red), textAlign: TextAlign.center))
                      ],
                    ),
                  )
                ],
              ),
            )
          )
        ],
      )
    );
  }
}

