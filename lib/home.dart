import 'package:flutter/material.dart';
import 'package:koyevi_kurye/view/main/siparis_takip/siparis_takip_view.dart';
import 'package:koyevi_kurye/view/main/teslim_al/teslim_al_view.dart';
import 'package:koyevi_kurye/view/main/teslim_et/teslim_et_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;

  bool _isPageCanChanged = true;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _pageController = PageController(keepPage: false);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _isPageCanChanged = false;
        _pageController.animateToPage(_tabController.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else {
        _isPageCanChanged = true;
      }
    });

    _pageController.addListener(() {
      if (_isPageCanChanged) {
        _tabController.animateTo(_pageController.page!.round());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          leadingWidth: 0,
          centerTitle: true,
          title: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Sipariş Takip'),
              Tab(text: 'Teslim Al'),
              Tab(text: 'Teslim Et'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SiparisTakipView();
              } else if (index == 1) {
                return const TeslimAlView();
              } else {
                return const TeslimEtView();
              }
            },
          ),
        ),
      ),
    ));
  }
}
