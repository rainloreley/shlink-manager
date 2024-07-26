import 'package:flutter/material.dart';
import 'package:shlink_app/API/server_manager.dart';
import 'package:shlink_app/main.dart';
import '../globals.dart' as globals;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _serverUrlController;
  late TextEditingController _apiKeyController;

  bool _isLoggingIn = false;
  String _errorMessage = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _serverUrlController = TextEditingController();
    _apiKeyController = TextEditingController();
  }

  void _connect() async {
    setState(() {
      _isLoggingIn = true;
      _errorMessage = "";
    });
    final connectResult = await globals.serverManager
        .initAndConnect(_serverUrlController.text, _apiKeyController.text);
    connectResult.fold((l) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InitialPage()));
      setState(() {
        _isLoggingIn = false;
      });
    }, (r) {
      if (r is ApiFailure) {
        setState(() {
          _errorMessage = r.detail;
          _isLoggingIn = false;
        });
      } else if (r is RequestFailure) {
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
            const SliverAppBar.medium(
                title: Text("Add server",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            SliverFillRemaining(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        "Server URL",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Row(
                    children: [
                      const Icon(Icons.dns_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextField(
                        controller: _serverUrlController,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "https://shlink.example.com"),
                      ))
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text("API Key",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.key),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextField(
                        controller: _apiKeyController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: "..."),
                      ))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => {_connect()},
                          child: _isLoggingIn
                              ? Container(
                                  width: 34,
                                  height: 34,
                                  padding: const EdgeInsets.all(4),
                                  child: const CircularProgressIndicator(),
                                )
                              : const Text("Connect",
                                  style: TextStyle(fontSize: 20)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Text(_errorMessage,
                                style: TextStyle(color: Theme.of(context).colorScheme.onError),
                                textAlign: TextAlign.center))
                      ],
                    ),
                  )
                ],
              ),
            ))
          ],
        ));
  }
}
