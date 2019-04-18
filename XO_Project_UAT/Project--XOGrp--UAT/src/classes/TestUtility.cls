@isTest
public with sharing class TestUtility {
    /**
     *  Container for test specific utilities
     */

    /**
     * Runs positive assertion between two passed values, outputs a standardized message on failure
     *
     * @param String what
     * @param Object itShouldBe
     * @param Object itIs
     */
    public static void itShouldBe(String what, Object itShouldBe, Object itIs) {
        String msg = String.format('{0} is {1} but should be {2}', new List<String>{what, String.valueOf(itIs), String.valueOf(itShouldBe)});
        System.assertEquals(itShouldBe, itIs, msg);
    }

    /**
     * Runs negative assertion between two passed variables, outputs a standardized message on failure
     *
     * @param what
     * @param itShouldNotBe
     * @param itIs
     */
    public static void itShouldNotBe(String what, Object itShouldNotBe, Object itIs) {
        String msg = String.format('{0} is {1} but should not be', new List<String>{what, String.valueOf(itShouldNotBe)});
        System.assertNotEquals(itShouldNotBe, itIs, msg);
    }
}