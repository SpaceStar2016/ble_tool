import 'package:flutter/cupertino.dart';

import '../../app_base_page.dart';

class BleRowDetailView extends AppBaseStatefulPage {
  const BleRowDetailView({super.key});

  @override
  State<BleRowDetailView> createState() => _BleRowDetailViewState();
}

class _BleRowDetailViewState extends AppBaseStatefulPageState<BleRowDetailView> {


  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }

  @override
  Widget body(BuildContext context) {
    return const Placeholder();
  }
}
