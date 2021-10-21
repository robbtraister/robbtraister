export default {
  roots: ["<rootDir>/src"],
  transform: {
    "^.+\\.tsx?$": "ts-jest",
  },
  testEnvironment: "jest-environment-jsdom",
};
