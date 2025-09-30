import '../../models/anekdot.dart';
import '../../models/user.dart';

class AnekdotArgs {
  final AnekdotModel? anekdot;
  final User? murid;

  AnekdotArgs({this.anekdot, this.murid});
}
