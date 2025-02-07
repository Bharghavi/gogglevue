// eslint.config.js
export default [
  {
    ignores: ["node_modules", "dist"], // Ignore unnecessary folders
  },
  {
    languageOptions: {
      ecmaVersion: "latest", // Use latest JavaScript syntax
      sourceType: "module", // Enable ES6 import/export
    },
    rules: {
      "object-curly-spacing": ["error", "never"], // Fixes space issues in {foo}
      "indent": ["error", 2], // Enforce 2-space indentation
      "max-len": ["warn", { "code": 100 }], // Allow longer lines
      "no-unused-vars": "warn", // Warn instead of error for unused variables
    },
  },
];
