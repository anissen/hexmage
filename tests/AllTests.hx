
package tests;

import tests.MinimaxTests;
import mohxa.Mohxa;

class AllTests extends Mohxa {
    static function main() {
        var tests = [
            new MinimaxTrivialTests(),
            new MinimaxTrivialTests2(),
            new MinimaxMultiTurnPlanningTests(),
            new MinimaxFailingTest()
        ];
        var failed = 0;
        for (test in tests) {
            failed += test.failed;
        }
        trace('=================================================');
        trace('Failed: $failed (ran ${tests.length} test suite(s))');
    }
}
