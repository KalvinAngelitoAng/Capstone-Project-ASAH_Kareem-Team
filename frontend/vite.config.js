import { defineConfig } from "vite";
import { resolve } from "path";

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
        login: resolve(__dirname, "src/pages/auth/login/login.html"),
        register: resolve(__dirname, "src/pages/auth/register/register.html"),
        mineHome: resolve(
          __dirname,
          "src/pages/mine-planner/home/home_planner_page.html"
        ),
        shippingHome: resolve(
          __dirname,
          "src/pages/shipping-planner/home/home_shipping_page.html"
        ),
        crew: resolve(
          __dirname,
          "src/pages/mine-planner/crew/crew_management_page.html"
        ),
        equipment: resolve(
          __dirname,
          "src/pages/mine-planner/equipment/equipment.html"
        ),
        pit: resolve(__dirname, "src/pages/mine-planner/pit/pit.html"),
        targetProduction: resolve(
          __dirname,
          "src/pages/mine-planner/target_production/target_production.html"
        ),
      },
    },
  },
});
