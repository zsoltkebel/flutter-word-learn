import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_learn/features/authentication/bloc/authentication_bloc.dart';
import 'package:word_learn/features/database/bloc/database_bloc.dart';
import 'package:word_learn/model/user_model.dart';
import 'package:word_learn/welcome_view.dart';
import 'package:word_learn/widgets/collection_tile.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationFailure) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WelcomeView()),
              (route) => false);
        }
      },
      buildWhen: ((previous, current) {
        if (current is AuthenticationFailure) {
          return false;
        }
        return true;
      }),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text((state as AuthenticationSuccess).user!.displayName!),
            actions: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    context
                        .read<AuthenticationBloc>()
                        .add(AuthenticationSignedOut());
                  })
            ],
          ),
          body: BlocBuilder<DatabaseBloc, DatabaseState>(
            builder: (context, state) {
              UserModel? user = (context.read<AuthenticationBloc>().state
                      as AuthenticationSuccess)
                  .user;
              String? displayName = user?.displayName;
              if (state is DatabaseSuccess &&
                  displayName !=
                      (context.read<DatabaseBloc>().state as DatabaseSuccess)
                          .displayName) {
                context.read<DatabaseBloc>().add(DatabaseFetched(displayName));
              }
              if (state is DatabaseInitial) {
                context
                    .read<DatabaseBloc>()
                    .add(DatabaseCollectionsFetched(user));
                return const Center(child: CircularProgressIndicator());
              } else if (state is DatabaseCollectionsSuccess) {
                if (state.collections.isEmpty) {
                  return const Center(
                    child: Text('Constants.textNoData'),
                  );
                } else {
                  return Center(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<DatabaseBloc>()
                            .add(DatabaseCollectionsFetched(user));
                      },
                      child: ListView.builder(
                        itemCount: state.collections.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CollectionTile(
                              folder: state.collections[index]);
                        },
                      ),
                    ),
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }
}
