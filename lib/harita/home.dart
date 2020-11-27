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
  var markerSayisi = 0;
  Iterable markers = [];
  LatLng _initialCameraPosition = LatLng(40.2228416, 28.8628205);
  GoogleMapController _controller;
  Location _location = Location();

  //Marker'lar ve BottomNavigationBar için başlangıç değeri verilmeli, verilen başlangıç değerleri:
  int secenek = 0;
  String sec = "pharmacy";

  @override
  void initState() {
    super.initState();
    getData(sec);
  }

  void _onMapCreated(GoogleMapController _cntrl) async {
    _controller = _cntrl;

    _location.onLocationChanged.listen((l) {
      lng = LatLng(l.latitude, l.longitude);
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 12),
        ),
      );
    });
    await getData(sec);
  }

  LatLng lng; //Ekranın bulunduğu konuma göre
  void _onCameraMove(CameraPosition position) {
    lng = position.target;
  }

  getData(String secim) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lng.latitude},${lng.longitude}&radius=4000&type=$secim&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI';

      final response = await http.get(url);
      final int statusCode = response.statusCode;

      for (var i = 0; i < markerSayisi; i++) {
        _checkWindow() async {
          final marker = MarkerId("marker$i");
          print(marker.toString());
          try {
            bool window = await _controller.isMarkerInfoWindowShown(marker);
            if (window) {
              _controller.hideMarkerInfoWindow(marker);
            }
          } catch (e) {
            print(e.toString());
          }
        }

        await _checkWindow();
        print(i);
      }

      if (statusCode == 201 || statusCode == 200) {
        Map responseBody = json.decode(response.body);
        List results = responseBody["results"];
        Iterable _markers = Iterable.generate(results.length, (index) {
          //results.lenght: Gelen results Listesinin uzunluğu sayısında marker oluşturur.
          Map result = results[index];
          Map location = result["geometry"]["location"];
          String _title = result["name"]; //Marker noktasındaki işletmenin ismi
          String _adres = result["vicinity"]; //İşletme adresi

          LatLng latLngMarker = LatLng(
            location["lat"],
            location["lng"],
          );

          return Marker(
            markerId: MarkerId("marker$index"),
            position: latLngMarker,
            infoWindow: InfoWindow(
              title: _title,
              snippet: _adres,
              // anchor: Offset(0.0, 0.0),
            ),
          );
        });
        markerSayisi = results.length;

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

  changeMap(int a) async {
    //BottomNavigationBar seçili index kontrolü ve index değişikliği durumunda marker'ları güncelle.
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
    await getData(sec);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Harita Konum"),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            markers: Set.from(
              markers,
            ),
            initialCameraPosition:
                CameraPosition(target: _initialCameraPosition, zoom: 14.5),
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
    );
  }
}
