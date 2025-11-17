const path = require('path');
const glob = require('glob');
const HardSourceWebpackPlugin = require('hard-source-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';

  return {
    optimization: {
      minimizer: [
        new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
        new OptimizeCSSAssetsPlugin({})
      ]
    },
    entry: {
      'profile': ["./js/profile/index.js"],
      "move_item": ["./js/move_item/index.js"],
      "client": ["./js/client/index.js"],
      "user": ["./js/user/index.js"],
      'seller_group': ["./js/seller_group/index.js"],
      'seller_group_background': ["./js/seller_group/draggable_background.js"],
      'admin': ["./js/admin/index.js"],
      'lightbox': ["./js/lightbox.min.js"],
      'quill.bubble': ["./css/quill/quill.bubble.css"],
      'quill.core': ["./css/quill.core.css"],
      'quill.snow': ["./css/quill.snow.css"],
      'quill.bubble': ["./css/quill.bubble.css"],
      'badges-styles': ["./css/badges-styles.css"],
      'jobs': ["./js/jobs/index.js"],
      'form_jobs': ["./js/jobs/form.js"],
      'job_apply': ["./js/jobs/apply.js"],
      'booking_popup': ["./js/booking/popup.js"],
      'draggable-background': ["./js/draggable-background.js"],
      "bootstrap-tagsinput.min": ["./js/bootstrap-tagsinput.min.js"],
      "notifications": ["./js/notifications.js"],
      'firebase-messaging-sw': ["./js/firebase-messaging-sw.js"],
      "map": ["./js/booking/map.js"],
      "jquery.translate": ["./js/chime-translate/jquery.translate.js"],
      "recorder": ["./js/recorder.js"],
      "recording": ["./js/recording.js"],
      "websocket": ["./js/websocket.js"],
      "chatbot_iframe": ["./js/chatbot_iframe.js"],
      "jquery.overlayhole": ["./js/jquery.overlayhole.js"]
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, '../priv/static/assets/js'),
      publicPath: '/js/'
    },
    devtool: devMode ? 'eval-cheap-module-source-map' : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader'
          }
        },
        {
          test: /\.(png|jpg|jpeg)$/,
          use: [
            {
              loader: "file-loader",
              options: {
                name: "[name].[ext]",
                outputPath: "../css/",
                publicPath: "../css"
              }
            }
          ]
        },
        {
          test: /\.[s]?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader'
          ],
        }
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: '../css/[name].css' }),
      new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
    ]
    .concat(devMode ? [new HardSourceWebpackPlugin()] : [])
  }
};
