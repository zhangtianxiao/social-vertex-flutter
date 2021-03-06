import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "config/constants.dart" as constants;
import 'utils/util.dart' as util;

class RegisterPage extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<RegisterPage> {
  String _userName = "";
  String _password = "";
  String _repassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("用户注册"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          TextField(
            textAlign: TextAlign.start,
            onChanged: (value) {
              _userName = value;
            },
            decoration: InputDecoration(labelText: "用户名"),
          ),
          TextField(
            textAlign: TextAlign.start,
            obscureText: true,
            onChanged: (String value) {
              _password = value;
            },
            decoration: InputDecoration(labelText: "密码"),
          ),
          TextField(
            obscureText: true,
            onChanged: (String value) {
              _repassword = value;
            },
            decoration: InputDecoration(labelText: "确认密码"),
          ),
          SizedBox.fromSize(
            size: Size(0.0, 10.0),
          ),
          Center(
            child: RaisedButton(
              onPressed: () {
                if (_userName != "" && _password != "" && _repassword != "") {
                  if (_password == _repassword) {
                    _register();
                  } else {
                    _registerAlert("两次密码不匹配");
                  }
                } else {
                  _registerAlert("信息不完整");
                }
              },
              child: Text("注册"),
            ),
          ),
        ],
      ),
    );
  }

  void _register() async {
    var password = util.md5(_password);
    var info = {
      constants.type: constants.user,
      constants.subtype: constants.register,
      constants.id: "$_userName",
      constants.password: "$password"
    };
    HttpClient client = HttpClient();
    try {
      client
          .put(constants.server, constants.httpPort, "/${constants.user}/${constants.register}")
          .then((HttpClientRequest request) {
        request.write(json.encode(info) + constants.end);
        return request.close();
      }).then((response) {
        response.transform(utf8.decoder).listen((data) {
          var resultData = json.decode(data);
          print(resultData);
          _registerAlert(resultData[constants.register] == true
              ? "注册成功"
              : resultData[constants.info] != null ? resultData[constants.info] : "注册失败");
        });
      });
    } catch (e) {
      if (client != null) client.close();
    }
  }

  void _registerAlert(String info) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
            title: Text("消息"),
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(info),
              ),
              SizedBox.fromSize(
                size: Size(0.00, 10.00),
              ),
              Align(
                alignment: Alignment.center,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("确定"),
                ),
              ),
            ],
          ),
    );
  }
}