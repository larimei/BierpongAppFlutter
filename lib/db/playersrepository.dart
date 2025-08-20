import 'package:bierpongapp/db/db.dart';
import 'package:bierpongapp/db/stores.dart';
import 'package:sembast/sembast.dart';
import '../domain/player.dart';

class PlayersRepository {
  Future<void> upsert(Player p) async {
    final db = await AppDb.instance();
    await playersStore.record(p.id).put(db, p.toJson());
  }

  Future<List<Player>> list({String? query}) async {
    final db = await AppDb.instance();
    final finder = (query == null || query.isEmpty)
        ? Finder(sortOrders: [SortOrder('nameLower')])
        : Finder(
            filter: Filter.matchesRegExp(
              'nameLower',
              RegExp(RegExp.escape(query.toLowerCase())),
            ),
            sortOrders: [SortOrder('nameLower')],
          );
    final snaps = await playersStore.find(db, finder: finder);
    return snaps
        .map((s) => Player.fromJson(Map<String, dynamic>.from(s.value)))
        .toList();
  }

  Future<void> delete(String id) async {
    final db = await AppDb.instance();
    await playersStore.record(id).delete(db);
  }
}
