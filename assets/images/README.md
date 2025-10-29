# Background Images

## Dubai Skyline Image

Please add your Dubai skyline image here with the filename: `dubai_skyline.jpg`

The image should be:
- Landscape orientation
- Recommended resolution: 1920x600 pixels or higher
- Format: JPG or PNG
- Shows the Dubai skyline at sunset/golden hour

Once you add the image, run `flutter pub get` to refresh the assets, then restart the app.

## Alternative: Use a Network Image

If you prefer to use a network image instead of a local asset, you can use:
```dart
image: DecorationImage(
  image: NetworkImage('YOUR_IMAGE_URL_HERE'),
  fit: BoxFit.cover,
),
```
