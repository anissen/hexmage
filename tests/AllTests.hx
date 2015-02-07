
package tests;

import tests.MinimaxTests;
import mohxa.Mohxa;

class AllTests extends Mohxa {
    static function main() {
        new MinimaxTrivialTests();
        new MinimaxTrivialTests2();
        // new MinimaxMultiTurnPlanningTests();
        // new MinimaxTests();
    }
}
