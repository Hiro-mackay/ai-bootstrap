declare module '*.svg' {
  const path: string;
  export default path;
}

declare module '*.module.css' {
  const classes: { readonly [key: string]: string };
  export default classes;
}
