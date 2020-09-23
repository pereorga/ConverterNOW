import 'package:converterpro/pages/ConversionPage.dart';
import 'package:converterpro/pages/ReorderPage.dart';
import 'package:converterpro/utils/Localization.dart';
import 'package:converterpro/utils/UnitsData.dart';
import 'package:converterpro/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import "dart:convert";

double appBarSize;
Map jsonSearch;
const MAX_CONVERSION_UNITS=19;
class ConversionManager extends StatefulWidget{

  final Function openDrawer;
  final int currentPage;
  final Function changeToPage;
  final List<String> listaTitoli;
  final bool showRateSnackBar;
  final List conversionsList;
  final List conversionsOrder;
  final String lastUpdateCurrency;
  final currencyValues;
  final bool isCurrenciesLoading;

  ConversionManager(this.openDrawer, this.currentPage, this.changeToPage, this.listaTitoli, this.showRateSnackBar, this.conversionsList, this.conversionsOrder, this.lastUpdateCurrency, this.currencyValues, this.isCurrenciesLoading);

  @override
  _ConversionManager createState() => new _ConversionManager();

}

class _ConversionManager extends State<ConversionManager>{
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  final SearchDelegate _searchDelegate=CustomSearchDelegate();
  final GlobalKey<ScaffoldState> scaffoldKey =GlobalKey();
  List conversionsOrder;
  List conversionsList;

  @override
  void initState() {
    conversionsOrder=widget.conversionsOrder;
    conversionsList=widget.conversionsList;
        
    if(!kIsWeb && widget.showRateSnackBar){
      Future.delayed(const Duration(seconds: 5), () {
        _showReviewSnackBar();
      });
    }
    super.initState();  
  }

  _onSelectItem(int index) {
    if(widget.currentPage!=index) {
      conversionsList[widget.currentPage].clearSelectedNode();
      widget.changeToPage(index);
    }
  }

  _getJsonSearch(BuildContext context) async {
    jsonSearch ??= json.decode(await DefaultAssetBundle.of(context).loadString("resources/lang/${Localizations.localeOf(context).languageCode}.json"));
  }

  _saveOrders() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> toConvertList=new List();
    for(int item in conversionsOrder[widget.currentPage])
      toConvertList.add(item.toString());
    prefs.setStringList("conversion_${widget.currentPage}", toConvertList);
  }

  _changeOrderUnita(BuildContext context,String title, List listaStringhe) async{
    List<String> listaUnitaTradotte = List();
    for(String stringa in listaStringhe)
      listaUnitaTradotte.add(MyLocalizations.of(context).trans(stringa));
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReorderPage(
            listaElementi: listaUnitaTradotte,
        ),));
    List arrayCopia=new List(conversionsOrder[widget.currentPage].length);
    for(int i=0;i<conversionsOrder[widget.currentPage].length;i++)
      arrayCopia[i]=conversionsOrder[widget.currentPage][i];
    setState(() {
      for(int i=0;i<conversionsOrder[widget.currentPage].length;i++)
        conversionsOrder[widget.currentPage][i]=result.indexOf(arrayCopia[i]);
      conversionsList=initializeUnits(conversionsOrder, widget.currencyValues); 
    });
    _saveOrders();
  }

  _showReviewSnackBar(){

    final SnackBar positiveResponseSnackBar = SnackBar(
      duration: const Duration(milliseconds: 4000),
      behavior: SnackBarBehavior.floating,
      content: Text(MyLocalizations.of(context).trans('valuta_app3'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
      action: SnackBarAction(
        label: MyLocalizations.of(context).trans('valuta_app5'),
        textColor: Theme.of(context).accentColor,
        onPressed: (){
          prefs.setBool("stop_request_rating", true);
          launchURL("https://play.google.com/store/apps/details?id=com.ferrarid.converterpro");
        },
      ),
    );

    final SnackBar negativeResponseSnackBar = SnackBar(
      duration: const Duration(milliseconds: 3000),
      behavior: SnackBarBehavior.floating,
      content: Text(MyLocalizations.of(context).trans('valuta_app4'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
      action: SnackBarAction(
        label: MyLocalizations.of(context).trans('valuta_app5'),
        textColor: Theme.of(context).accentColor,
        onPressed: (){
          prefs.setBool("stop_request_rating", true);
          launchURL("https://play.google.com/store/apps/details?id=com.ferrarid.converterpro");
        },
      ),
    );

    final SnackBar reviewSnackBar = SnackBar(
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      content: SizedBox(
        height: 69.0,
        child: Center(
          child: Column(
            children: <Widget>[
              Text(MyLocalizations.of(context).trans('valuta_app2'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text(MyLocalizations.of(context).trans('valuta_app2NO'), style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: (){
                      scaffoldKey.currentState.hideCurrentSnackBar();
                      scaffoldKey.currentState.showSnackBar(negativeResponseSnackBar);
                    },
                  ),
                  FlatButton(
                    child: Text(MyLocalizations.of(context).trans('valuta_app2SI'), style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: (){
                      scaffoldKey.currentState.hideCurrentSnackBar();
                      scaffoldKey.currentState.showSnackBar(positiveResponseSnackBar);
                    },
                  ),
                ]
              )
            ],
          ),
        ),
      ),
    );
    scaffoldKey.currentState.showSnackBar(reviewSnackBar);
  }

  @override
  Widget build(BuildContext context) {
    _getJsonSearch(context);

    List<Choice> choices = <Choice>[
      Choice(title: MyLocalizations.of(context).trans('riordina'), icon: Icons.reorder),
    ];
    
    return Scaffold(
      key:scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(child:ConversionPage(conversionsList[widget.currentPage],widget.listaTitoli[widget.currentPage], widget.currentPage==11 ? widget.lastUpdateCurrency : "", MediaQuery.of(context), widget.isCurrenciesLoading)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Builder(builder: (context) {
              return IconButton(
                tooltip: MyLocalizations.of(context).trans('menu'),
                icon: Icon(Icons.menu,color: Colors.white,),
                onPressed: () {
                widget.openDrawer();
              });
            }),
            Row(children: <Widget>[
              IconButton(
                tooltip: MyLocalizations.of(context).trans('elimina_tutto'),
                icon: Icon(Icons.clear,color: Colors.white),
                onPressed: () {
                  setState(() {
                    conversionsList[widget.currentPage].clearAllValues();
                  });
                },),
              IconButton(
                tooltip: MyLocalizations.of(context).trans('cerca'),
                icon: Icon(Icons.search,color: Colors.white,),
                onPressed: () async {
                  final int paginaReindirizzamento=await showSearch(context: context,delegate: _searchDelegate);
                  if(paginaReindirizzamento!=null)
                    _onSelectItem(paginaReindirizzamento);
                },
              ),
              PopupMenuButton<Choice>(
                icon: Icon(Icons.more_vert,color: Colors.white,),
                onSelected: (Choice choice){
                  _changeOrderUnita(context, MyLocalizations.of(context).trans('mio_ordinamento'), conversionsList[widget.currentPage].getStringOrderedNodiFiglio());
                },
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
            ],)
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        tooltip: MyLocalizations.of(context).trans('calcolatrice'),
        child: Image.asset("resources/images/calculator.png",width: 30.0,),
        onPressed: (){
          showModalBottomSheet<void>(context: context,
            builder: (BuildContext context) {
              double displayWidth=MediaQuery.of(context).size.width;
              return Calculator(Theme.of(context).accentColor, displayWidth); 
            }
          );
        },
        elevation: 5.0,
        backgroundColor: Theme.of(context).accentColor,//Color(0xff2196f3)//listaColori[currentPage],
      )
    );
  }
}


class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}


class CustomSearchDelegate extends SearchDelegate<int> {  

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
        final List<SearchUnit> _dataSearch=initializeSearchUnits((int pageNumber){close(context,pageNumber);}, jsonSearch);
        final List<SearchGridTile> allConversions=initializeGridSearch((int pageNumber) {close(context, pageNumber);}, jsonSearch, MediaQuery.of(context).platformBrightness==Brightness.dark);

        final Iterable<SearchUnit> suggestions = _dataSearch.where((searchUnit) => searchUnit.unitName.toLowerCase().contains(query.toLowerCase())); //.toLowercase per essere case insesitive
        
        return query.isNotEmpty ? SuggestionList(
          suggestions: suggestions.toList(),
          darkMode: MediaQuery.of(context).platformBrightness==Brightness.dark,
        )
        : GridView(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0),
          children: allConversions,
          
        );
      }
    
      @override
      Widget buildResults(BuildContext context) {
        return Container();
      }
    
      @override
      List<Widget> buildActions(BuildContext context) {
        return <Widget>[
          if(query.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            ),
        ];
      }
}
