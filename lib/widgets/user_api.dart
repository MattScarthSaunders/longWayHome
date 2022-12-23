import 'dart:convert';

import 'package:http/http.dart' as http;

postUser(userEmail) async {
  return await http.post(
      Uri.parse("https://rich-puce-bear-gown.cyclic.app/api/user"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "email": userEmail,
      }));
}

getUser(userEmail) async {
  return await http.get(Uri.parse(
      "https://rich-puce-bear-gown.cyclic.app/api/user/email/${userEmail}"));
}

postNewRoute(userID, routeName, routeData) async {
  return await http.post(
      Uri.parse(
          "https://rich-puce-bear-gown.cyclic.app/api/user/${userID}/route"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "routeName": routeName,
        "routeData": routeData,
      }));
}

patchRoute(userID, routeID, routeName) async {
  return await http.patch(
      Uri.parse(
          "https://rich-puce-bear-gown.cyclic.app/api/user/${userID}/routes/${routeID}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "newName": routeName,
      }));
}

deleteRoute(userID, routeID, routeName) async {
  return await http.delete(Uri.parse(
      "https://rich-puce-bear-gown.cyclic.app/api/user/${userID}/routes/${routeID}"));
}
