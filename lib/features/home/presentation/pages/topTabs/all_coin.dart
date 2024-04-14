import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/dialogs/custom_generic_dialog.dart';
import '../../../../../core/router/routes.dart';
import '../../../../home/presentation/bloc/home_bloc.dart';
import '../../../../home/presentation/widgets/item.dart';
import '../../bloc/coin_list_status.dart';

class AllCoins extends StatefulWidget {
  const AllCoins({super.key});

  @override
  State<AllCoins> createState() => _AllCoinsState();
}

class _AllCoinsState extends State<AllCoins>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(
                Icons.refresh_outlined,
                color: Theme.of(context).primaryColor,
                size: 25,
              ),
              onPressed: () {
              //  context.read<HomeBloc>().add(GetAllCoinsEvent());
              },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(GetAllCoinsEvent());
        },
        child:

            BlocConsumer<HomeBloc, HomeState>(
              listener: (context, state) {
                if (state.coinListStatus is CoinsListError) {
                  final error = state.coinListStatus as CoinsListError;
                  customGenericDialog(message: error.message, context: context);
                }
              },
              builder: (context, state) {
                if (state.coinListStatus is CoinsListLoaded) {
                  final data = state.coinListStatus as CoinsListLoaded;
                  return ListView(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children:[
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                          child: RichText(
                            text: const TextSpan(
                              text: r'$',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '50000.32',
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Center(
                        child: Text('Portfolio Value'),
                      ),
                      Center(
                        child: Text(
                          '+1562.28 (%67)',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      const Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            'Wallet',
                            style: TextStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                  ...?data.data.data?.map((item) {
                    final timestamp = data.data.timestamp!;
                    final percentDouble = double.tryParse(item.changePercent24Hr!);
                    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
                      return Item(
                        onTap: () {
                          context.goNamed(Routes.name[RouteName.history]!,
                              extra: <String, dynamic>{
                                'interval': 'd1',
                                'symbolId': item.id ?? '',
                                'percentChange': percentDouble ?? 0.0,
                                'name': item.name ?? "",
                                'price': '\$ ${item.priceUsd ?? '0.0'}',
                              });
                        },
                        item: item,
                        time: date.toLocal().toString(),
                        percent: percentDouble ?? 0.0,
                      );
                    },
                  )]);
                } else if (state is CoinsListError) {
                  final error = state.coinListStatus as CoinsListError;
                  return Center(child: Text(error.message));
                } else {
                  return const SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
                }
              },
            ),

    ));
  }

  @override
  bool get wantKeepAlive => true;
}
