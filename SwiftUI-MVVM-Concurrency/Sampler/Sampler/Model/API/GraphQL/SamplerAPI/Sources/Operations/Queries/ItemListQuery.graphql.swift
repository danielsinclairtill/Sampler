// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct ItemListQuery: GraphQLQuery {
  public static let operationName: String = "ItemList"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ItemList($first: Int, $after: String) { posts(first: $first, after: $after) { __typename nodes { __typename ...ItemCompactGraph } totalCount pageInfo { __typename endCursor hasNextPage hasPreviousPage startCursor } } }"#,
      fragments: [ItemCompactGraph.self, UserGraph.self]
    ))

  public var first: GraphQLNullable<Int32>
  public var after: GraphQLNullable<String>

  public init(
    first: GraphQLNullable<Int32>,
    after: GraphQLNullable<String>
  ) {
    self.first = first
    self.after = after
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "first": first,
    "after": after
  ] }

  public struct Data: SamplerAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { SamplerAPI.Objects.Query }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("posts", Posts.self, arguments: [
        "first": .variable("first"),
        "after": .variable("after")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ItemListQuery.Data.self
    ] }

    /// List of posts
    public var posts: Posts { __data["posts"] }

    /// Posts
    ///
    /// Parent Type: `PostConnection`
    public struct Posts: SamplerAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { SamplerAPI.Objects.PostConnection }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("nodes", [Node?]?.self),
        .field("totalCount", Int.self),
        .field("pageInfo", PageInfo.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        ItemListQuery.Data.Posts.self
      ] }

      /// A list of nodes.
      public var nodes: [Node?]? { __data["nodes"] }
      /// Total count of items
      public var totalCount: Int { __data["totalCount"] }
      /// Information to aid in pagination.
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// Posts.Node
      ///
      /// Parent Type: `Post`
      public struct Node: SamplerAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { SamplerAPI.Objects.Post }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(ItemCompactGraph.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ItemListQuery.Data.Posts.Node.self,
          ItemCompactGraph.self
        ] }

        public var body: String { __data["body"] }
        public var id: Int { __data["id"] }
        public var title: String { __data["title"] }
        public var user: User { __data["user"] }

        public struct Fragments: FragmentContainer {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          public var itemCompactGraph: ItemCompactGraph { _toFragment() }
        }

        public typealias User = ItemCompactGraph.User
      }

      /// Posts.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: SamplerAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { SamplerAPI.Objects.PageInfo }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("endCursor", String?.self),
          .field("hasNextPage", Bool.self),
          .field("hasPreviousPage", Bool.self),
          .field("startCursor", String?.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          ItemListQuery.Data.Posts.PageInfo.self
        ] }

        /// When paginating forwards, the cursor to continue.
        public var endCursor: String? { __data["endCursor"] }
        /// When paginating forwards, are there more items?
        public var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating backwards, are there more items?
        public var hasPreviousPage: Bool { __data["hasPreviousPage"] }
        /// When paginating backwards, the cursor to continue.
        public var startCursor: String? { __data["startCursor"] }
      }
    }
  }
}
