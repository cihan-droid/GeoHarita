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

  //Marker'lar ve BottomNavigationBar için başlangıç değeri verilmeli, verilen başlangıç değerleri:
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
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 12),
        ),
      );
    });
    getData(sec);
  }

  LatLng lng; //Ekranın bulunduğu konuma göre
  void _onCameraMove(CameraPosition position) {
    lng = position.target;
  }

  // 1. denemem

  // getPic(String gorsel) async {
  //   var imageData = BitmapDescriptor.defaultMarker;
  //   // var _list = photoList.iterator;
  //   // print(photoList[0]);
  //   // print(_list);

  //   try {
  //     final String picUrl =
  //         "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$gorsel&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI";

  //     final responsePic = await http.get(picUrl);
  //     final int picStatusCode = responsePic.statusCode;
  //     print("responsePic StatusCode: ${responsePic.statusCode}");
  //     if (picStatusCode == 201 || picStatusCode == 200) {
  //       imageData = await json.decode(responsePic.body);
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //   return imageData;
  // }

  // 2. denemem

  // getPic(String yazi) async {
  //   //   // var imageData;
  //   //   // print("PhotoRef: $yazi");
  //   //   // try {
  //   //   //   final String picUrl =
  //   //   //       "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$yazi&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI";

  //   //   //   final responsePic = await http.get(picUrl).then((value) => imageData);
  //   //   //   final int picStatusCode = responsePic.statusCode;
  //   //   //   print("responsePic StatusCode: ${responsePic.statusCode}");
  //   //   //   // if (picStatusCode == 201 || picStatusCode == 200) {
  //   //   //   //   // imageData = BitmapDescriptor.fromBytes(responsePic.bodyBytes);
  //   //   //   //   imageData = json.decode(responsePic.body);
  //   //   //   // }
  //   //   // } catch (e) {
  //   //   //   print(e.toString());
  //   //   // }
  //   //   // return imageData;

  //   // **** 3. Denemem, üstteki kısmı metod içerisinde yoruma alıp alttaki halini denemiştim. ****

  //   //   // String imageUrl =
  //   //   //     "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$yazi&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI";
  //   //   // final http.Response response = await http.get(imageUrl);

  //   //   // BitmapDescriptor.fromBytes(response.bodyBytes);

  //   //   // final int targetWidth = 60;
  //   //   // final File markerImageFile =
  //   //   //     await DefaultCacheManager().getSingleFile(imageUrl);

  //   //   // final Uint8List markerImageBytes = await markerImageFile.readAsBytes();

  //   //   // final markerImageCodec =
  //   //   //     await instantiateImageCodec(markerImageBytes, targetWidth: targetWidth);

  //   //   // final FrameInfo frameInfo = await markerImageCodec.getNextFrame();

  //   //   // final ByteData byteData = await frameInfo.image.toByteData(
  //   //   //   format: ImageByteFormat.png,
  //   //   // );

  //   //   // final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();

  //   //   // BitmapDescriptor.fromBytes(resizedMarkerImageBytes);
  //   //   // return resizedMarkerImageBytes;

  //   // ***** 4. denemem *****

  //   // Metod, yorumların üzerinde başlıyor.

  //   var iconUrl =
  //       "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${yazi}&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI";
  //   var dataBytes;
  //   var request = await http.get(
  //       iconUrl); //Debug sırasında buraya ve bir alt satıra break point koyduğumda isteğin buraya geldiğini görebiliyorum, ancak bu GET isteği yapıldıktan sonra hata veriyor, alttaki satırdan devam etmiyor.
  //   var bytes = request.bodyBytes;

  //   setState(() {
  //     dataBytes = bytes;
  //   });

  //   return dataBytes.buffer.asUint8List();
  // }

  getData(String secim) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lng.latitude},${lng.longitude}&radius=4000&type=$secim&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI';

      print("Çalışıyor...");
      final response = await http.get(url);
      final int statusCode = response.statusCode;

      if (statusCode == 201 || statusCode == 200) {
        Map responseBody = json.decode(response.body);
        List results = responseBody["results"];
        Iterable _markers = Iterable.generate(results.length, (index) {
          //results.lenght: Gelen results Listesinin uzunluğu sayısında marker oluşturur.
          Map result = results[index];
          print(results[index]);

          Map location = result["geometry"]["location"];
          LatLng latLngMarker = LatLng(
            location["lat"],
            location["lng"],
          );

          // **** Burada bulunan yoruma alınmış satırlarla bu metod içerisinde de Places API çağrısı için deneme yapmıştım. ******

          // String photoUrlString = result["photos"][0][
          //     "photo_reference"]; //API'de bulunan photo_reference key'ini elde edebilmek için.
          // final String picUrl =
          //     "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoUrlString&key=AIzaSyA_npCi92eXFj_r73CidIM3f_CArsra_NI";

          // final responsePic = await http.get(picUrl);
          // // final int picStatusCode = responsePic.statusCode;
          // print("responsePic StatusCode: ${responsePic.statusCode}");
          // // if (picStatusCode == 201 || picStatusCode == 200) {
          // //   imageData = BitmapDescriptor.fromBytes(responsePic.bodyBytes);
          // // }
          // imageData = BitmapDescriptor.fromBytes(responsePic.bodyBytes);

          print("Location: $location");
          String _title = result["name"]; //Marker noktasındaki işletmenin ismi
          print("Title: $_title");
          String _adres = result["vicinity"]; //İşletme adresi
          // List sonuc = result["photos"];
          // var picString = sonuc["photo_reference"];

          // String gorsel = result["photos"]["photo_reference"];  HATALI ÇAĞRI
          // print(gorsel);

          // var photoRef =
          //     result["photos"]["photo_reference"]; //Photos bilgileri için  HATALI ÇAĞRI
          // print(photoRef);
          // BitmapDescriptor test = getPic(result["photos"]);
          bool infoCheck(MarkerId id) {
            _controller.isMarkerInfoWindowShown(id).then((value) {
              return value;
            });
            return false;
          }

          for (var i = 0; i < results.length; i++) {
            // Farklı seçenek seçildiğinde marker pin'leri üzerinde açık olan bütün InfOWindow pencerelerini kapatır. VSCode Üzerinde hata veriyor, CMD ile çalıştırılınca hata mesajı vermiyor! *****
            if (infoCheck(MarkerId("marker$i")) == true) {
              _controller.hideMarkerInfoWindow(MarkerId("marker$i"));
            }
          }

          return Marker(
            markerId: MarkerId("marker$index"),
            position: latLngMarker,
            infoWindow: InfoWindow(
              title: _title,
              snippet: _adres,
              // anchor: Offset(0.0, 0.0),
            ),
            // icon: BitmapDescriptor(getPic(photoUrlString)),
          );
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

  changeMap(int a) {
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
    getData(sec);
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
