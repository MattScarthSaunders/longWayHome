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
      "https://rich-puce-bear-gown.cyclic.app/api/user/email/$userEmail"));
}

getRoutes(userID) async {
  return await http.get(
    Uri.parse("https://rich-puce-bear-gown.cyclic.app/api/user/$userID/routes"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

postNewRoute(userID, routeName, startCoord, endCoord, poiCoords) async {
  return await http.post(
      Uri.parse(
          "https://rich-puce-bear-gown.cyclic.app/api/user/$userID/route"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "routeName": routeName,
        'routeData': {"start": startCoord, "end": endCoord, "POIs": poiCoords}
      }));
}

patchRoute(userID, routeID, routeName) async {
  return await http.patch(
      Uri.parse(
          "https://rich-puce-bear-gown.cyclic.app/api/user/$userID/routes/$routeID"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "newName": routeName,
      }));
}

deleteRoute(userID, routeID, routeName) async {
  print('deleting...');
  return await http.delete(Uri.parse(
      "https://rich-puce-bear-gown.cyclic.app/api/user/$userID/routes/$routeID"));
}
