import 'package:bierpongapp/db/db.dart';
import 'package:bierpongapp/db/stores.dart';
import 'package:sembast/sembast.dart';
import '../domain/tournament.dart';

class TournamentsRepository {
  Future<void> upsert(Tournament t) async {
    final db = await AppDb.instance();
    await tournamentsStore.record(t.id).put(db, t.toJson());
  }

  Future<List<Tournament>> list({String? query}) async {
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
    final snaps = await tournamentsStore.find(db, finder: finder);
    return snaps
        .map((s) => Tournament.fromJson(Map<String, dynamic>.from(s.value)))
        .toList();
  }

  Future<void> delete(String id) async {
    final db = await AppDb.instance();
    await tournamentsStore.record(id).delete(db);
  }
}
