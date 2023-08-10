import 'package:api_rest/models/peliculapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:api_rest/models/gif.dart';


class Api extends StatefulWidget {
  const Api({super.key});

  @override
  State<Api> createState() => _ApiState();
}


class _ApiState extends State<Api> {
  //Variables que reciben respuestas en un listado 
  late Future<List<PeliculaApi>> _listadoPeli;
  late Future<List<Gif>> _listadoGifs;

  //Recibe una lista de peliculas en un futuro
  Future<List<PeliculaApi>> _getPelis() async{

    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/now_playing?api_key=bfee52afbf7a5d3c60d59acfe03473a6&language=es-ES&page=1'));

    List<PeliculaApi> peliculas = [];

    if(response.statusCode == 200){
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData['results']) {
        peliculas.add(
          PeliculaApi(
            adult: item['adult'],
            backdropPath: item['backdrop_path'],
            genreIds: item['genre_ids'],
            id: item['id'],
            originalLanguage: item['original_language'],
            originalTitle: item['original_title'],
            overview: item['overview'],
            popularity: item['popularity'],
            posterPath: item['poster_path'],
            releaseDate: item['release_date'],
            title: item['title'],
            video: item['video'],
            voteAverage: item['vote_average'].toString(),
            voteCount: item['vote_count']
          )
        );
      }
      return peliculas;
    }else{
      throw Exception('fallo la conexión');
    }
  }

  //Recibe una lista de gifs
  Future<List<Gif>> _getGifs() async {
    final response = await http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=C9lAOsr6BweCcUcNOrtIyQypZBUmZqfr&limit=10&rating=g"));
    

    List<Gif> gifs = [];
    if(response.statusCode == 200){

      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData['data']) {
        gifs.add(
          Gif(item['title'], item['images']['downsized']['url'])
        );
      }
      return gifs;
    }else{
      throw Exception('fallo la conexión');
    }
  }

  @override
  void initState() {
    super.initState();
    _listadoGifs = _getGifs();
    _listadoPeli = _getPelis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text('PELICULAS'),
        actions: [
          Container(
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text('FR'),
            ),
          ),
          SizedBox(width: 8.0,)
        ],
      ),
      body: ListView(
        children: [
          //
          FutureBuilder(
            future: _listadoPeli,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: _BannerList(snapshot.data!),
                );
              }else if(snapshot.hasError){
                print(snapshot.error);
                return Text('Error');
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Text('Nuevas',style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.redAccent),),

          FutureBuilder(
            future: _listadoPeli,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: _PeliculasList(snapshot.data!),
                );
              }else if(snapshot.hasError){
                print(snapshot.error);
                return Text('Error');
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: GNav(
            backgroundColor: Colors.black,
            activeColor: Colors.white,
            color: Colors.white,
            tabBackgroundColor: Colors.redAccent.shade200,
            gap: 8.0,
            padding: EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.favorite_border,
                  text: 'Favorites',
                ),
                GButton(
                  icon: Icons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: Icons.settings,
                  text: 'Settings',
                ),
              ],
            ),
        ),
      ),
    );
  }
  
  List<Widget> _listGifs( List<Gif> data ) {
    List<Widget> gifs = [];

    for (var gif in data) {
      gifs.add(
        Text(gif.name)
      );
    }
    return gifs;
  }

  Widget _buildCarousel( List<Gif> data){
    return CarouselSlider(
      items: data.map((gif) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Image.network(
            gif.url,
            fit: BoxFit.cover,
          ),
        );
      }).toList(),
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        
      ),
    );
  }

  Widget _nextCarousel(){
    return CarouselSlider(
            items: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                color: Colors.green,
              ),
              Container(
                color: Colors.blue,
              ),
              Container(
                color: Colors.yellow,
              ),
              Container(
                color: Colors.purple,
              ),
            ],
            options: CarouselOptions(
              height: 400,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 16/9,
              autoPlayCurve: Curves.easeOutCirc,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
      );
  }
  
  Widget _PeliculasList(List<PeliculaApi> data ) {
    String ima = 'https://image.tmdb.org/t/p/w500';

    return CarouselSlider(
      items: data.map((gif) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
            ima + gif.backdropPath,
            fit: BoxFit.cover,
          ),
  ),
);
      }).toList(),
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        
      ),
    );
  }

    Widget _BannerList(List<PeliculaApi> data ) {
    String ima = 'https://image.tmdb.org/t/p/w500';

    return CarouselSlider(
      items: data.map((gif) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
            ima + gif.posterPath,
            fit: BoxFit.cover,
          ),
  ),
);
      }).toList(),
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 3 / 2,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        viewportFraction: 0.38,
        
      ),
    );
  }

}


