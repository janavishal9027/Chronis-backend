package com.chronis.engineering;
import org.junit.jupiter.api.Test;
import java.time.*;
import static org.junit.jupiter.api.Assertions.*;
class EngineeringPolicyTest {
    private Instant at(String time){return LocalDate.of(2026,11,5).atTime(LocalTime.parse(time)).atZone(EngineeringPolicy.ZONE).toInstant();}
    @Test void exactPlanBoundariesAndDayNumbers(){assertEquals(92,EngineeringPolicy.dayNumber(LocalDate.of(2027,2,4)));assertEquals(LocalDate.of(2026,11,5),EngineeringPolicy.dateForDay(1));assertFalse(EngineeringPolicy.applies(LocalDate.of(2027,2,5)));assertThrows(IllegalArgumentException.class,()->EngineeringPolicy.dateForDay(93));}
    @Test void earlyAndOnTimeLoginAreAllowedWithoutChangingLogout(){var d=LocalDate.of(2026,11,5);assertDoesNotThrow(()->EngineeringPolicy.validateLogin(d,at("08:59"),null));assertDoesNotThrow(()->EngineeringPolicy.validateLogin(d,at("09:00"),null));assertDoesNotThrow(()->EngineeringPolicy.validateLogin(d,at("08:59"),"Approved exceptional early session"));assertThrows(Exception.class,()->EngineeringPolicy.validateLogin(d,at("17:00"),null));}
    @Test void logoutRequiresTimeAndReportOnTheServer(){var d=LocalDate.of(2026,11,5);assertThrows(Exception.class,()->EngineeringPolicy.validateLogout(d,at("16:54"),true,null));assertThrows(Exception.class,()->EngineeringPolicy.validateLogout(d,at("16:55"),false,null));assertDoesNotThrow(()->EngineeringPolicy.validateLogout(d,at("16:55"),true,null));assertDoesNotThrow(()->EngineeringPolicy.validateLogout(d,at("12:00"),false,"Medical emergency; submit report later"));assertThrows(Exception.class,()->EngineeringPolicy.validateLogout(d,at("12:00"),false,"short"));}
    @Test void midnightDoesNotFabricateAValidNormalLogout(){var d=LocalDate.of(2026,11,5);assertThrows(Exception.class,()->EngineeringPolicy.validateLogout(d,at("16:55").plusSeconds(86400),true,null));}
    @Test void lateLogoutRequiresAReason(){assertThrows(Exception.class,()->EngineeringPolicy.validateLogout(LocalDate.of(2026,11,5),at("17:01"),true,null));}
}
