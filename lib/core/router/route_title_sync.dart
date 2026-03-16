import 'package:btg_funds_manager/core/router/route_names.dart';
import 'package:btg_funds_manager/core/router/web_page_title.dart';

const Map<String, String> kRouteTitles = <String, String>{
  RouteNames.funds: 'Fondos disponibles',
  RouteNames.transactions: 'Historial de transacciones',
};

void syncPageTitle([String? routeName]) {
  WebPageTitle.set(kRouteTitles[routeName]);
}
