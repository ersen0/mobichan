import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobichan/dependency_injector.dart';
import 'package:mobichan/features/core/core.dart';
import 'package:mobichan/features/post/post.dart';
import 'package:mobichan_domain/mobichan_domain.dart';
import 'package:shimmer/shimmer.dart';

class ThreadsPage extends StatelessWidget {
  final Board board;

  const ThreadsPage(this.board, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThreadsCubit>(
      create: (context) => sl<ThreadsCubit>()..getThreads(board, Sort.initial),
      child: BlocConsumer<ThreadsCubit, ThreadsState>(
        listener: (context, state) {
          if (state is ThreadsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              errorSnackbar(
                context,
                state.message,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ThreadsLoaded) {
            return buildLoaded(state);
          } else {
            return buildLoading();
          }
        },
      ),
    );
  }

  Widget buildLoaded(ThreadsLoaded state) {
    return BlocListener<SearchCubit, SearchState>(
      listener: (context, state) {
        final threadsCubit = context.read<ThreadsCubit>();
        if (state is Searching) {
          threadsCubit.search(state.input);
        }
        if (state is NotSearching) {
          threadsCubit.search('');
        }
      },
      child: ListView.separated(
        itemCount: state.threads.length,
        separatorBuilder: (context, index) => const Divider(
          height: 0,
          thickness: 1,
        ),
        itemBuilder: (context, index) {
          Post thread = state.threads[index];
          return ThreadWidget(
            thread: thread,
            board: board,
          );
        },
      ),
    );
  }

  Widget buildLoading() {
    return ListView.builder(
      itemBuilder: (context, index) => buildThreadShimmer(),
    );
  }

  Widget buildThreadShimmer() {
    return Builder(builder: (context) {
      double deviceWidth = MediaQuery.of(context).size.width;
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade700,
        highlightColor: Colors.grey.shade600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: deviceWidth,
                    height: 15.0,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    width: deviceWidth * 0.5,
                    height: 15.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            // Image
            Container(
              height: 250.0,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      SizedBox(width: 30.0),
                      Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ],
                  ),
                  Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
