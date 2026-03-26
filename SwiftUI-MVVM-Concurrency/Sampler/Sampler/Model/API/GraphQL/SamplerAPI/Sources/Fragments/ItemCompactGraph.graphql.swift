// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

public struct ItemCompactGraph: SamplerAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ItemCompactGraph on post { __typename body id title user { __typename ...UserGraph } }"#
  }

  @_spi(Unsafe) public let __data: DataDict
  @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

  @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { SamplerAPI.Objects.Post }
  @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("body", String.self),
    .field("id", Int.self),
    .field("title", String.self),
    .field("user", User.self),
  ] }
  @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
    ItemCompactGraph.self
  ] }

  public var body: String { __data["body"] }
  public var id: Int { __data["id"] }
  public var title: String { __data["title"] }
  public var user: User { __data["user"] }

  /// User
  ///
  /// Parent Type: `User`
  public struct User: SamplerAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { SamplerAPI.Objects.User }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .fragment(UserGraph.self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ItemCompactGraph.User.self,
      UserGraph.self
    ] }

    public var id: Int { __data["id"] }
    public var name: String { __data["name"] }

    public struct Fragments: FragmentContainer {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      public var userGraph: UserGraph { _toFragment() }
    }
  }
}
