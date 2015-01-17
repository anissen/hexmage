
import mohxa.Mohxa;

class UnitTest extends Mohxa {

    public function new() {
        super();

        describe('Game Test', function(){

            log('we will create 2 different stacks');
            log('one with ints, one with strings');

            it('should each start with a 0 length', function(){
                equal(0, 0, 'int stack');
                equal(0, 0, 'string stack');
            });

        });

        run();
    }

    static function main() {
        new UnitTest();
    }
}
