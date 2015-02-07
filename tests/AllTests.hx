
package tests;

import tests.MinimaxTests;
import mohxa.Mohxa;

class AllTests extends Mohxa {
    static function main() {
        var failed = 
            new MinimaxTrivialTests().failed +
            new MinimaxTrivialTests2().failed +
            new MinimaxMultiTurnPlanningTests().failed +
            new MinimaxFailingTest().failed;
        trace('=================================================');
        trace('Failed: $failed');
    }
}
