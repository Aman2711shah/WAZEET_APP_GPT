library dataconnect_generated;

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_movie.dart';
part 'upsert_user.dart';
part 'add_review.dart';
part 'delete_review.dart';
part 'list_movies.dart';
part 'list_users.dart';
part 'list_user_reviews.dart';
part 'get_movie_by_id.dart';
part 'search_movie.dart';

// Helper functions for JSON conversion
T nativeFromJson<T>(dynamic value) {
  if (value == null) {
    throw ArgumentError('Cannot convert null to non-nullable type $T');
  }

  if (T == String) {
    return value.toString() as T;
  } else if (T == int) {
    return (value is int ? value : int.parse(value.toString())) as T;
  } else if (T == double) {
    return (value is double ? value : double.parse(value.toString())) as T;
  } else if (T == bool) {
    return (value is bool ? value : value.toString().toLowerCase() == 'true')
        as T;
  } else if (T == DateTime) {
    return (value is DateTime ? value : DateTime.parse(value.toString())) as T;
  }

  return value as T;
}

dynamic nativeToJson<T>(T value) {
  if (value is DateTime) {
    return value.toIso8601String();
  }
  return value;
}

class ExampleConnector {
  CreateMovieVariablesBuilder createMovie({
    required String title,
    required String genre,
    required String imageUrl,
  }) {
    return CreateMovieVariablesBuilder(
      dataConnect,
      title: title,
      genre: genre,
      imageUrl: imageUrl,
    );
  }

  UpsertUserVariablesBuilder upsertUser({required String username}) {
    return UpsertUserVariablesBuilder(dataConnect, username: username);
  }

  AddReviewVariablesBuilder addReview({
    required String movieId,
    required int rating,
    required String reviewText,
  }) {
    return AddReviewVariablesBuilder(
      dataConnect,
      movieId: movieId,
      rating: rating,
      reviewText: reviewText,
    );
  }

  DeleteReviewVariablesBuilder deleteReview({required String movieId}) {
    return DeleteReviewVariablesBuilder(dataConnect, movieId: movieId);
  }

  ListMoviesVariablesBuilder listMovies() {
    return ListMoviesVariablesBuilder(dataConnect);
  }

  ListUsersVariablesBuilder listUsers() {
    return ListUsersVariablesBuilder(dataConnect);
  }

  ListUserReviewsVariablesBuilder listUserReviews() {
    return ListUserReviewsVariablesBuilder(dataConnect);
  }

  GetMovieByIdVariablesBuilder getMovieById({required String id}) {
    return GetMovieByIdVariablesBuilder(dataConnect, id: id);
  }

  SearchMovieVariablesBuilder searchMovie() {
    return SearchMovieVariablesBuilder(dataConnect);
  }

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'wazeetappgpt',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
      dataConnect: FirebaseDataConnect.instanceFor(
        connectorConfig: connectorConfig,
        sdkType: CallerSDKType.generated,
      ),
    );
  }

  FirebaseDataConnect dataConnect;
}
