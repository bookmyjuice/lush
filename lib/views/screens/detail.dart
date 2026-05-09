import 'package:flutter/material.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/main.dart';
import 'package:lush/views/models/model.dart';
import 'package:toastification/toastification.dart';

//detail class
class DetailPage extends StatefulWidget {
  // Declare a field that holds product

  static const routeName = '/productDetails';
  final Product product;
  const DetailPage(this.product, {super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  //holder for product

  late final Product product;
  int items = 1;

  @override
  void initState() {
    product = widget.product;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: product.nameColor,
      appBar: AppBar(
        backgroundColor: product.nameColor,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 50),
            child: Icon(Icons.shopping_cart_outlined),
          )
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        details(context),
        image(context),
      ],
    );
  }

  Widget image(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .25,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * .1,
        right: 20,
      ),
      child: Align(
          alignment: Alignment.topRight,
          child: Hero(
            tag: product.name,
            child: Image.asset(
              product.imgUrl,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * .6,
            ),
          )),
    );
  }

  Widget details(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topDetailContainer(context),
        _bottomDetailContainer(context),
      ],
    );
  }

  Widget _topDetailContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "The Sweetest Juice Point",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Price",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                product.price,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _bottomDetailContainer(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
            ),
            Text(
              product.details,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                        ),
                        onPressed: () {
                          if (items > 1) {
                            items = items - 1;
                          }
                          setState(() {}); //rebuild
                        },
                      ),
                      Text(
                        items.toString().padLeft(2, '0'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                        ),
                        onPressed: () {
                          items = items + 1;
                          setState(() {}); //rebuild
                        },
                      ),
                    ],
                  ),
                  //like btn
                  IconButton(
                    icon: product.liked
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.pink,
                          )
                        : const Icon(
                            Icons.favorite_border_outlined,
                            color: Colors.pink,
                          ),
                    onPressed: () {
                      if (product.liked) {
                        product.likes = product.likes - 1;
                        product.liked = false;
                      } else {
                        product.likes = product.likes + 1;
                        product.liked = true;
                      }
                      setState(() {}); //rebuild
                    },
                  ),
                ],
              ),
            ),
            Align(
              child: InkWell(
                onTap: () {
                  // Buy Now - Add to cart (MVP - simplified)
                  // Show success message for now
                  toastification.show(
                    type: ToastificationType.success,
                    title: Text('${widget.product.name} - Feature coming soon!'),
                    alignment: Alignment.topCenter,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  height: 60,
                  // width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                      color: product.nameColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50))),
                  child: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          children: <TextSpan>[
                        TextSpan(text: "Buy Now"),
                        // TextSpan(text: "129 ", style: TextStyle(decoration: TextDecoration.lineThrough)),
                        // TextSpan(text: "98/juice",style: TextStyle(fontWeight: FontWeight.bold))
                      ])),
                  // const Text(
                  //   "Buy Now",
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white),
                  // ),
                ),
              ),
            ),
            Align(
              child: InkWell(
                onTap: () async {
                  // Subscribe - Navigate to subscription plans
                  try {
                    final userRepository = getIt.get<UserRepository>();
                    final urls = await userRepository.getSubscriptionPageUrl();

                    if (mounted) {
                      Navigator.pushNamed(context, '/subscriptions',
                        arguments: SubscriptionPageUrlArgument(
                          premium_page_url: urls['premium'] ?? '',
                          signature_page_url: urls['signature'] ?? '',
                          delight_page_url: urls['delight'] ?? '',
                        ),
                      );
                    }
                  } catch (e) {
                    toastification.show(
                      type: ToastificationType.error,
                      title: const Text('Unable to load subscriptions'),
                      description: Text('Error: $e'),
                      alignment: Alignment.topCenter,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  height: 60,
                  // width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                      color: product.nameColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50))),
                  child: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          children: <TextSpan>[
                        TextSpan(text: "Subscribe @Rs."),
                        TextSpan(
                            text: "129 ",
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.w100)),
                        TextSpan(
                            text: "89/juice",
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ])),
                  // Text(
                  //   "Subscribe",
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white),
                  // ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
