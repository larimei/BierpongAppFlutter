import 'package:bierpongapp/db/db.dart';
import 'package:bierpongapp/db/stores.dart';
import 'package:sembast/sembast.dart';
import '../domain/team.dart';

class TeamsRepository {
  Future<void> upsert(Team t) async {
    final db = await AppDb.instance();
    await teamsStore.record(t.id).put(db, t.toJson());
  }

  Future<List<Team>> list({String? query}) async {
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
    final snaps = await teamsStore.find(db, finder: finder);
    return snaps
        .map((s) => Team.fromJson(Map<String, dynamic>.from(s.value)))
        .toList();
  }

  Future<void> delete(String id) async {
    final db = await AppDb.instance();
    await teamsStore.record(id).delete(db);
  }
}
