import 'package:flutter/material.dart';
import 'package:douban_app/bean/subject_entity.dart';
import 'package:douban_app/bean/TopItemBean.dart';
import 'package:douban_app/http/http_request.dart';
import 'dart:math' as math;
import 'package:palette_generator/palette_generator.dart';
import 'package:douban_app/http/API.dart';

class MovieRepository {
  var _request = HttpRequest(API.BASE_URL);

  List<Subject> hotShowBeans; //影院热映
  List<Subject> comingSoonBeans; //即将上映
  List<Subject> hotBeans; //豆瓣榜单
  List<SubjectEntity> weeklyBeans; //一周口碑电影榜
  List<Subject> top250Beans; //Top250
  List<String> todayUrls;
  TopItemBean weeklyTopBean, weeklyHotBean, weeklyTop250Bean;
  Color weeklyTopColor, weeklyHotColor, weeklyTop250Color,todayPlayBg;


  MovieRepository(
  {this.hotShowBeans,
    this.comingSoonBeans,
    this.hotBeans,
    this.weeklyBeans,
    this.top250Beans,
    this.todayUrls,
    this.weeklyTopBean,
    this.weeklyHotBean,
    this.weeklyTop250Bean,
    this.weeklyTopColor,
    this.weeklyHotColor,
    this.weeklyTop250Color,
    this.todayPlayBg});

  Future<MovieRepository> requestAPI() async {
    ///影院热映
    var result = await _request.get(API.IN_THEATERS);
    var resultList = result['subjects'];
    hotShowBeans =
        resultList.map<Subject>((item) => Subject.fromMap(item)).toList();
    ///即将上映
    result = await _request.get('/v2/movie/coming_soon?apikey=0b2bdeda43b5688921839c8ecb20399b');
    resultList = result['subjects'];
    comingSoonBeans =
        resultList.map<Subject>((item) => Subject.fromMap(item)).toList();
    int start = math.Random().nextInt(220);
    result = await _request.get(API.TOP_250 + '?start=$start&count=7&apikey=0b2bdeda43b5688921839c8ecb20399b');
    resultList = result['subjects'];

    ///豆瓣榜单
    hotBeans =
        resultList.map<Subject>((item) => Subject.fromMap(item)).toList();
    ///一周热门电影榜
    weeklyHotBean = TopItemBean.convertHotBeans(hotBeans);
    var paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(hotBeans[0].images.medium));
    if (paletteGenerator != null && paletteGenerator.colors.isNotEmpty) {
      weeklyHotColor = (paletteGenerator.colors.toList()[0]);
    }

    ///一周口碑电影榜
    result = await _request.get(API.WEEKLY);
    resultList = result['subjects'];
    weeklyBeans = resultList
        .map<SubjectEntity>((item) => SubjectEntity.fromMap(item))
        .toList();
    weeklyTopBean = TopItemBean.convertWeeklyBeans(weeklyBeans);
    paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(weeklyBeans[0].subject.images.medium));
    if (paletteGenerator != null && paletteGenerator.colors.isNotEmpty) {
      weeklyTopColor = (paletteGenerator.colors.toList()[0]);
    }
    ///今日可播放电影
    start = math.Random().nextInt(220);
    result = await _request.get(API.TOP_250 + '?start=$start&count=7&apikey=0b2bdeda43b5688921839c8ecb20399b');
    resultList = result['subjects'];
    List<Subject> beans =
        resultList.map<Subject>((item) => Subject.fromMap(item)).toList();
    todayUrls = [];
    todayUrls.add(beans[0].images.medium);
    todayUrls.add(beans[1].images.medium);
    todayUrls.add(beans[2].images.medium);
    paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(todayUrls[0]));
    if (paletteGenerator != null && paletteGenerator.colors.isNotEmpty) {
      todayPlayBg = (paletteGenerator.colors.toList()[0]);
    }

    ///豆瓣TOP250
    result = await _request.get(API.TOP_250 + '?start=0&count=5&apikey=0b2bdeda43b5688921839c8ecb20399b');
    resultList = result['subjects'];
    top250Beans =
        resultList.map<Subject>((item) => Subject.fromMap(item)).toList();
    weeklyTop250Bean = TopItemBean.convertTopBeans(top250Beans);
    paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(top250Beans[0].images.medium));
    if (paletteGenerator != null && paletteGenerator.colors.isNotEmpty) {
      weeklyTop250Color = (paletteGenerator.colors.toList()[0]);
    }
    return MovieRepository(
        hotShowBeans:hotShowBeans,
        comingSoonBeans:comingSoonBeans,
        hotBeans:hotBeans,
        weeklyBeans:weeklyBeans,
        top250Beans:top250Beans,
        todayUrls:todayUrls,
        weeklyTopBean:weeklyTopBean,
        weeklyHotBean:weeklyHotBean,
        weeklyTop250Bean:weeklyTop250Bean,
        weeklyTopColor:weeklyTopColor,
        weeklyHotColor:weeklyHotColor,
        weeklyTop250Color:weeklyTop250Color,
        todayPlayBg:todayPlayBg);
  }
}
