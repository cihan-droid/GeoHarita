import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Harita extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HaritaState();
  }
}

class _HaritaState extends State<Harita> {
  Iterable markers = [];
  LatLng _initialCameraPosition = LatLng(40.2228416, 28.8628205);
  GoogleMapController _controller;
  Location _location = Location();

  int secenek = 0;
  String sec = "pharmacy";

  @override
  void initState() {
    super.initState();

    getData(sec);
  }

  void _onMapCreated(GoogleMapController _cntrl) {
    _controller = _cntrl;

    _location.onLocationChanged.listen((l) {
      lng = LatLng(l.latitude, l.longitude);
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 14.5),
        ),
      );
      getData(sec);
    });
  }

  changeMap(int a) {
    setState(() {
      if (a == 0) {
        sec = "pharmacy";
        secenek = 0;
      }
      if (a == 1) {
        sec = "bank";
        secenek = 1;
      }
      if (a == 2) {
        sec = "gas_station";
        secenek = 2;
      }
    });
    getData(sec);
  }

  LatLng lng; //Ekranın bulunduğu konuma göre
  void _onCameraMove(CameraPosition position) {
    lng = position.target;
  }

  getData(String secim) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lng.latitude},${lng.longitude}&radius=8000&type=$secim&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI';
      final response = await http.get(url);

      final int statusCode = response.statusCode;

      if (statusCode == 201 || statusCode == 200) {
        Map responseBody = json.decode(response.body);
        List results = responseBody["results"];
        Iterable _markers = Iterable.generate(5, (index) {
          Map result = results[index];
          Map location = result["geometry"]["location"];
          String _title = result["name"];
          LatLng latLngMarker = LatLng(
            location["lat"],
            location["lng"],
          );
          return Marker(
              markerId: MarkerId("marker$index"),
              position: latLngMarker,
              infoWindow: InfoWindow(
                title: _title,
              ));
        });

        setState(() {
          markers = _markers;
        });
      } else {
        throw Exception('Hata!');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set.from(
              markers,
            ),
            initialCameraPosition:
                CameraPosition(target: _initialCameraPosition, zoom: 9),
            mapType: MapType.terrain,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: false,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => changeMap(index),
        currentIndex: secenek,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: 'Eczane',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_outlined),
            label: 'Banka',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Akaryakıt',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text("Harita Konum"),
      ),
    );
  }
}
