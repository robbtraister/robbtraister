import path from "path";

import webpack from "webpack";

import { dependencies } from "./package.json";

const PRODUCTION_PATTERN = /^prod/i;
export function getIsProd(mode: string) {
  return (
    PRODUCTION_PATTERN.test(process.env.NODE_ENV || "") ||
    PRODUCTION_PATTERN.test(mode)
  );
}

export function getVendorAliases() {
  // for all prod dependencies, enforce the root version due to react context sharing
  return Object.fromEntries(
    Object.keys(dependencies).map((dep) => [
      dep,
      path.resolve(__dirname, "node_modules", dep),
    ])
  );
}

export function getVendorRules(isProd: boolean) {
  return [
    {
      test: /\.tsx?$/,
      exclude: /\/node_modules\//,
      use: {
        loader: "ts-loader",
        options: {
          compilerOptions: {
            jsx: isProd ? "react-jsx" : "react-jsxdev",
          },
          transpileOnly: true,
        },
      },
    },
  ];
}

function getDependencies() {
  return (
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    Object.keys(dependencies || {})
      // react-query/devtools are not exposed via the root import
      .concat("react-query/devtools")
      .filter((dep) => {
        // verify that an import exists for this module
        try {
          require.resolve(dep);
        } catch (e: any) {
          if (e.code === "MODULE_NOT_FOUND") {
            return false;
          }
        }
        return true;
      })
  );
}

export default (
  env: Partial<Record<string, string>>,
  argv: { mode: string }
) => {
  const isProd = getIsProd(argv.mode);
  const hash = env.HASH || "[hash]";

  return {
    devtool: "cheap-source-map",
    // build a static script that includes each of the following modules
    entry: {
      vendors: getDependencies(),
    },
    mode: isProd ? "production" : "development",
    // use the same rules configuration as other builds
    module: {
      rules: getVendorRules(isProd),
    },
    output: {
      devtoolNamespace: "vendors",
      filename: "[name].js",
      path: path.resolve(__dirname, "public"),
      // expose the modules via a global require function called `vendors_abc123` (or whatever)
      library: `[name]_${hash}`,
    },
    performance: {
      maxAssetSize: 100 * 2 ** 20, // 100MB
      maxEntrypointSize: 100 * 2 ** 20, // 100MB
    },
    plugins: [
      // export a manifest file to be used by dev config
      new webpack.DllPlugin({
        path: path.join(__dirname, "public", "[name]-manifest.json"),
        name: `[name]_${hash}`,
        entryOnly: false,
      }),
    ],
    resolve: {
      alias: getVendorAliases(),
    },
    watch: false,
  };
};
