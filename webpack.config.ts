import path from "path";

import CssMinimizerPlugin from "css-minimizer-webpack-plugin";
import ForkTsCheckerWebpackPlugin from "fork-ts-checker-webpack-plugin";
import HtmlWebpackPlugin from "html-webpack-plugin";
import HtmlWebpackTagsPlugin from "html-webpack-tags-plugin";
import MiniCssExtractPlugin from "mini-css-extract-plugin";
import TerserWebpackPlugin from "terser-webpack-plugin";
import TsconfigPathsWebpackPlugin from "tsconfig-paths-webpack-plugin";

import {
  Configuration,
  DllReferencePlugin,
  WebpackPluginInstance,
} from "webpack";

import { name, version } from "./package.json";
import { getIsProd, getVendorRules } from "./webpack.vendors";

export default function getConfig(
  _env: Partial<Record<string, string>>,
  arg: { mode: string }
): Configuration {
  const isProd = getIsProd(arg.mode);

  const pathPrefix = `/${name}`;

  return {
    entry: "./src",
    mode: isProd ? "production" : "development",
    module: {
      rules: [
        ...getVendorRules(isProd),
        {
          test: /\.s?css$/,
          use: [
            isProd
              ? {
                  loader: MiniCssExtractPlugin.loader,
                }
              : "style-loader",
          ],
        },
        {
          test: /\.css$/,
          use: [
            {
              loader: "css-loader",
              options: {
                sourceMap: isProd,
              },
            },
          ],
        },
        {
          test: /\.scss$/,
          use: [
            {
              loader: "css-loader",
              options: {
                sourceMap: isProd,
                modules: {
                  localIdentContext: path.resolve(__dirname, "src"),
                  localIdentName: isProd
                    ? "[local]__[contenthash:base64:5]"
                    : "[path][name]_[local]",
                  exportLocalsConvention: "camelCase",
                },
              },
            },
            {
              loader: "sass-loader",
              options: {
                sourceMap: isProd,
                sassOptions: {
                  fiber:
                    Number(process.versions.node.split(".")[0]) >= 16
                      ? false
                      : // this option does not support `true` as a value
                        undefined,
                  includePaths: ["./"],
                },
              },
            },
          ],
        },
        {
          test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
          use: "@svgr/webpack",
        },
      ],
    },
    optimization: {
      minimize: isProd,
      minimizer: [new TerserWebpackPlugin(), new CssMinimizerPlugin()],
    },
    output: {
      path: path.resolve(__dirname, "dist"),
    },
    plugins: [
      new ForkTsCheckerWebpackPlugin({
        eslint: {
          enabled: true,
          files: ["src/**/*.{ts,tsx}"],
          options: {
            ignorePattern: [
              "**/*.scss.d.ts",
              "**/*.stories.ts",
              "**/*.stories.tsx",
              "**/*.test.ts",
              "**/*.test.tsx",
            ],
          },
        },
        logger: {
          devServer: false,
        },
        typescript: {
          configFile: path.resolve(__dirname, "tsconfig.json"),
          configOverwrite: {
            include: ["./src/**/*", "./src/**/*.json"],
            exclude: [
              "**/*.stories.ts",
              "**/*.stories.tsx",
              "**/*.test.ts",
              "**/*.test.tsx",
            ],
          },
        },
      }),
      new HtmlWebpackPlugin({
        minify: isProd,
        scriptLoading: "defer",
        template: "./src/index.html",
        title: name,
        version,
      }),
      isProd &&
        new HtmlWebpackPlugin({
          filename: "404.html",
          minify: false,
          pathPrefix,
          scriptLoading: "defer",
          template: "./src/redirect.html",
          title: name,
          version,
        }),
      isProd &&
        new MiniCssExtractPlugin({
          filename: "[name].[contenthash].css",
          chunkFilename: "[name].[contenthash].css",
        }),
      !isProd &&
        // because the `vendors.js` artifact is built separately, HtmlWebpackPlugin doesn't know about it
        // HtmlWebpackTagsPlugin manually injects a <script src="/vendors.js"> tag into the index.html artifact
        new HtmlWebpackTagsPlugin({ tags: ["vendors.js"], append: false }),
      !isProd &&
        new DllReferencePlugin({
          context: __dirname,
          manifest: require("./public/vendors-manifest.json"),
        }),
    ].filter(Boolean) as WebpackPluginInstance[],
    resolve: {
      extensions: [".tsx", ".ts", ".jsx", ".mjs", ".js", ".json"],
      plugins: [
        new TsconfigPathsWebpackPlugin({
          configFile: path.resolve(__dirname, "tsconfig.json"),
        }),
      ],
    },
    devServer: {
      compress: true,
      open: "/index.html",
      watchFiles: "src/**/*",
    },
  };
}
