import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:couchbase_lite/couchbase_lite.dart';

void main() {
  group("Query creation", () {
    test("Select query", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Meta.id),
        SelectResult.property("name"),
        SelectResult.property("type"),
      ]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"name"}],[{"property":"type"}]]}');
    });

    From baseQuery = QueryBuilder.select([SelectResult.all()]).from("database");

    Map<String, dynamic> baseJson = {
      "selectDistinct": false,
      "selectResult": [
        [
          {"property": null}
        ]
      ],
      "from": {"database": "database"}
    };
    Expression limitExpr = Expression.intValue(10);
    Map<String, dynamic> limitJson = {
      "limit": [
        [
          {"intValue": 10}
        ]
      ]
    };
    Expression offsetExpr = Expression.intValue(10);
    Map<String, dynamic> limitOffsetJson = {
      "limit": [
        [
          {"intValue": 10}
        ],
        [
          {"intValue": 10}
        ]
      ]
    };
    List<Ordering> orderByExpr = [Ordering.property("country")];
    Map<String, dynamic> orderByJson = {
      "orderBy": [
        [
          {"property": "country"}
        ]
      ]
    };

    test("SelectFrom", () {
      expect(json.encode(baseQuery), json.encode(baseJson));
    });

    test("SelectFromAs", () {
      Query query = QueryBuilder.select(
              [SelectResult.expression(Meta.id.from("myAlias"))])
          .from("database", as: "myAlias");
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"},{"from":"myAlias"}]],"from":{"database":"database","as":"myAlias"}}');
    });

    test("SelectFromWhere", () {
      Query query = QueryBuilder.select([SelectResult.all()])
          .from("database")
          .where(
              Expression.property("type").equalTo(Expression.string("hotel")));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":null}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}]}');
    });

    test("SelectFromWhereOrderBy", () {
      Query query = QueryBuilder.select([SelectResult.all()])
          .from("database")
          .where(
              Expression.property("type").equalTo(Expression.string("hotel")))
          .orderBy([Ordering.expression(Meta.id)]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":null}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}],"orderBy":[[{"meta":"id"}]]}');
    });

    test("SelectFromWhereLimit", () {
      Query query = QueryBuilder.select([SelectResult.all()])
          .from("database")
          .where(
              Expression.property("type").equalTo(Expression.string("hotel")))
          .limit(Expression.intValue(10));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":null}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"hotel"}]}],"limit":[[{"intValue":10}]]}');
    });

    test("In", () {
      Query query = QueryBuilder.select([SelectResult.property("name")])
          .from("database")
          .where(Expression.property("country")
              .In([Expression.string("Latvia"), Expression.string("usa")]).and(
                  Expression.property("type")
                      .equalTo(Expression.string("airport"))))
          .orderBy([Ordering.property("name")]);
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"}]],"from":{"database":"database"},"where":[{"property":"country"},{"in":[[{"string":"Latvia"}],[{"string":"usa"}]]},{"and":[{"property":"type"},{"equalTo":[{"string":"airport"}]}]}],"orderBy":[[{"property":"name"}]]}');
    });

    test("like", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Meta.id),
        SelectResult.property("country"),
        SelectResult.property("name")
      ]).from("database").where(Expression.property("type")
          .equalTo(Expression.string("landmark"))
          .and(Expression.property("type")
              .like(Expression.string("Royal Engineers Museum"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"country"}],[{"property":"name"}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"landmark"}]},{"and":[{"property":"type"},{"like":[{"string":"Royal Engineers Museum"}]}]}]}');
    });

    test("regex", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Meta.id),
        SelectResult.property("country"),
        SelectResult.property("name")
      ]).from("database").where(Expression.property("type")
          .equalTo(Expression.string("landmark"))
          .and(Expression.property("name")
              .regex(Expression.string("\\bEng.*r\\b"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"meta":"id"}],[{"property":"country"}],[{"property":"name"}]],"from":{"database":"database"},"where":[{"property":"type"},{"equalTo":[{"string":"landmark"}]},{"and":[{"property":"name"},{"regex":[{"string":"\\\\bEng.*r\\\\b"}]}]}]}');
    });

    test("join", () {
      Query query = QueryBuilder.select([
        SelectResult.expression(Expression.property("name").from("airline")),
        SelectResult.expression(
            Expression.property("callsign").from("airline")),
        SelectResult.expression(
            Expression.property("destinationairport").from("route")),
        SelectResult.expression(Expression.property("stops").from("route")),
        SelectResult.expression(Expression.property("airline").from("route"))
      ])
          .from("airline")
          .join(Join.join("database", as: "route").on(Meta.id
              .from("airline")
              .equalTo(Expression.property("airlineid").from("route"))))
          .where(Expression.property("type")
              .from("route")
              .equalTo(Expression.string("route"))
              .and(Expression.property("type")
                  .from("airline")
                  .equalTo(Expression.string("airline")))
              .and(Expression.property("sourceairport")
                  .from("route")
                  .equalTo(Expression.string("RIX"))));
      expect(json.encode(query),
          '{"selectDistinct":false,"selectResult":[[{"property":"name"},{"from":"airline"}],[{"property":"callsign"},{"from":"airline"}],[{"property":"destinationairport"},{"from":"route"}],[{"property":"stops"},{"from":"route"}],[{"property":"airline"},{"from":"route"}]],"from":{"database":"airline"},"joins":[{"join":"database","as":"route"},{"on":[{"meta":"id"},{"from":"airline"},{"equalTo":[{"property":"airlineid"},{"from":"route"}]}]}],"where":[{"property":"type"},{"from":"route"},{"equalTo":[{"string":"route"}]},{"and":[{"property":"type"},{"from":"airline"},{"equalTo":[{"string":"airline"}]}]},{"and":[{"property":"sourceairport"},{"from":"route"},{"equalTo":[{"string":"RIX"}]}]}]}');
    });

    GroupBy groupBy = baseQuery.groupBy([Expression.property("country")]);
    Map<String, dynamic> groupByJson = Map.from(baseJson);
    groupByJson.addAll({
      "groupBy": [
        [
          {"property": "country"}
        ]
      ]
    });

    test("groupBy", () {
      expect(json.encode(groupBy), json.encode(groupByJson));
    });

    test("groupByLimit", () {
      Map expected = Map.from(groupByJson);
      expected.addAll(limitJson);
      expect(json.encode(groupBy.limit(limitExpr)), json.encode(expected));
    });

    test("groupByLimitOffset", () {
      Map expected = Map.from(groupByJson);
      expected.addAll(limitOffsetJson);
      expect(json.encode(groupBy.limit(limitExpr, offset: offsetExpr)),
          json.encode(expected));
    });

    test("groupByOrderBy", () {
      Map expected = Map.from(groupByJson);
      expected.addAll(orderByJson);
      expect(json.encode(groupBy.orderBy(orderByExpr)), json.encode(expected));
    });

    Having having = groupBy.having(
        Expression.property("country").equalTo(Expression.string("US")));

    Map<String, dynamic> havingJson = Map.from(groupByJson);
    havingJson.addAll({
      "having": [
        {"property": "country"},
        {
          "equalTo": [
            {"string": "US"}
          ]
        }
      ]
    });

    test("having", () {
      Map expected = Map.from(havingJson);
      expect(json.encode(having), json.encode(expected));
    });

    test("havingLimit", () {
      Map expected = Map.from(havingJson);
      expected.addAll(limitJson);
      expect(json.encode(having.limit(limitExpr)), json.encode(expected));
    });

    test("havingLimitOffset", () {
      Map expected = Map.from(havingJson);
      expected.addAll(limitOffsetJson);
      expect(json.encode(having.limit(limitExpr, offset: offsetExpr)),
          json.encode(expected));
    });

    test("havingOrderBy", () {
      Map expected = Map.from(havingJson);
      expected.addAll(orderByJson);
      expect(json.encode(having.orderBy(orderByExpr)), json.encode(expected));
    });
  });
}
