import '../../index/index_main.dart';

class NetworkCachedImage extends StatelessWidget {
  const NetworkCachedImage({
    Key? key,
    required this.image,
    this.width,
    this.height,
    this.boxFit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  final String image;
  final double? width;
  final double? height;
  final BoxFit boxFit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      width: width,
      height: height,
      fit: boxFit,
      placeholder:
          (context, url) =>
              placeholder ??
              SizedBox(
                width: width,
                height: height,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: ColorResources.COLOR_Primary,
                  ),
                ),
              ),
      errorWidget:
          (context, url, error) =>
              errorWidget ??
              Container(
                width: width ?? 100,
                height: height ?? 100,
                color: Colors.grey[200],
                child: NetworkCachedImage(
                  image: Strings.placeholder_image,
                  width: width ?? 100,
                  height: height ?? 100,
                ),
              ),
    );
  }
}
