package com.autora.rental.config;

import com.autora.rental.branch.Branch;
import com.autora.rental.branch.BranchRepository;
import com.autora.rental.car.*;
import com.autora.rental.employee.Employee;
import com.autora.rental.employee.EmployeeRepository;
import com.autora.rental.employee.EmployeeStatus;
import com.autora.rental.notification.Notification;
import com.autora.rental.notification.NotificationRepository;
import com.autora.rental.notification.NotificationType;
import com.autora.rental.user.Role;
import com.autora.rental.user.User;
import com.autora.rental.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final BranchRepository branchRepository;
    private final CarRepository carRepository;
    private final NotificationRepository notificationRepository;
    private final EmployeeRepository employeeRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        // Only initialize if database is empty
        if (userRepository.count() == 0) {
            initializeData();
        }
    }

    private void initializeData() {
        // Create main manager user (previously admin)
        User mainManager = User.builder()
                .fullName("Main Manager")
                .email("admin@autora.com")
                .phone("+970599000001")
                .password(passwordEncoder.encode("admin123"))
                .role(Role.MANAGER)
                .hireDate(LocalDate.of(2022, 1, 1))
                .status("active")
                .position("General Manager")
                .department("Management")
                .build();
        userRepository.save(mainManager);

        Employee mainManagerEmployee = Employee.builder()
                .user(mainManager)
                .position("General Manager")
                .department("Management")
                .hireDate(LocalDate.of(2022, 1, 1))
                .status(EmployeeStatus.ACTIVE)
                .tasksCompleted(200)
                .rating(5.0)
                .totalRatings(50)
                .build();
        employeeRepository.save(mainManagerEmployee);

        // Create sample user (customer)
        User sampleUser = User.builder()
                .fullName("John Doe")
                .email("john@example.com")
                .phone("+970599000002")
                .password(passwordEncoder.encode("password123"))
                .role(Role.USER)
                .build();
        userRepository.save(sampleUser);

        // Create manager user
        User managerUser = User.builder()
                .fullName("Sarah Manager")
                .email("manager@autora.com")
                .phone("+970599000003")
                .password(passwordEncoder.encode("manager123"))
                .role(Role.MANAGER)
                .hireDate(LocalDate.of(2023, 1, 15))
                .status("active")
                .position("Branch Manager")
                .department("Operations")
                .build();
        userRepository.save(managerUser);

        Employee manager = Employee.builder()
                .user(managerUser)
                .position("Branch Manager")
                .department("Operations")
                .hireDate(LocalDate.of(2023, 1, 15))
                .status(EmployeeStatus.ACTIVE)
                .tasksCompleted(150)
                .rating(4.9)
                .totalRatings(45)
                .build();
        employeeRepository.save(manager);

        // Create employee users
        User employee1User = User.builder()
                .fullName("Ahmad Driver")
                .email("ahmad@autora.com")
                .phone("+970599000004")
                .password(passwordEncoder.encode("employee123"))
                .role(Role.EMPLOYEE)
                .hireDate(LocalDate.of(2023, 6, 1))
                .status("active")
                .position("Driver")
                .department("Delivery")
                .build();
        userRepository.save(employee1User);

        Employee employee1 = Employee.builder()
                .user(employee1User)
                .position("Driver")
                .department("Delivery")
                .hireDate(LocalDate.of(2023, 6, 1))
                .status(EmployeeStatus.ACTIVE)
                .tasksCompleted(87)
                .rating(4.7)
                .totalRatings(32)
                .build();
        employeeRepository.save(employee1);

        User employee2User = User.builder()
                .fullName("Khaled Support")
                .email("khaled@autora.com")
                .phone("+970599000005")
                .password(passwordEncoder.encode("employee123"))
                .role(Role.EMPLOYEE)
                .hireDate(LocalDate.of(2023, 8, 15))
                .status("active")
                .position("Support Agent")
                .department("Customer Service")
                .build();
        userRepository.save(employee2User);

        Employee employee2 = Employee.builder()
                .user(employee2User)
                .position("Support Agent")
                .department("Customer Service")
                .hireDate(LocalDate.of(2023, 8, 15))
                .status(EmployeeStatus.ACTIVE)
                .tasksCompleted(45)
                .rating(4.5)
                .totalRatings(18)
                .build();
        employeeRepository.save(employee2);

        User employee3User = User.builder()
                .fullName("Mohammed Inspector")
                .email("mohammed@autora.com")
                .phone("+970599000006")
                .password(passwordEncoder.encode("employee123"))
                .role(Role.EMPLOYEE)
                .hireDate(LocalDate.of(2024, 1, 10))
                .status("active")
                .position("Vehicle Inspector")
                .department("Quality")
                .build();
        userRepository.save(employee3User);

        Employee employee3 = Employee.builder()
                .user(employee3User)
                .position("Vehicle Inspector")
                .department("Quality")
                .hireDate(LocalDate.of(2024, 1, 10))
                .status(EmployeeStatus.ACTIVE)
                .tasksCompleted(23)
                .rating(4.8)
                .totalRatings(12)
                .build();
        employeeRepository.save(employee3);

        // Create branches
        Branch downtown = Branch.builder()
                .name("Downtown Branch")
                .address("123 Main Street")
                .city("New York")
                .country("USA")
                .latitude(40.7128)
                .longitude(-74.0060)
                .phone("+1-212-555-0100")
                .email("downtown@autora.com")
                .openingTime("08:00")
                .closingTime("20:00")
                .isActive(true)
                .build();
        branchRepository.save(downtown);

        Branch airport = Branch.builder()
                .name("Airport Branch")
                .address("JFK International Airport")
                .city("New York")
                .country("USA")
                .latitude(40.6413)
                .longitude(-73.7781)
                .phone("+1-212-555-0200")
                .email("airport@autora.com")
                .openingTime("06:00")
                .closingTime("23:00")
                .isActive(true)
                .build();
        branchRepository.save(airport);

        Branch midtown = Branch.builder()
                .name("Midtown Branch")
                .address("456 5th Avenue")
                .city("New York")
                .country("USA")
                .latitude(40.7549)
                .longitude(-73.9840)
                .phone("+1-212-555-0300")
                .email("midtown@autora.com")
                .openingTime("07:00")
                .closingTime("21:00")
                .isActive(true)
                .build();
        branchRepository.save(midtown);

        List<Branch> allBranches = Arrays.asList(downtown, airport, midtown);

        // Create sample cars
        Car tesla = Car.builder()
                .name("Tesla Model 3")
                .brand("Tesla")
                .model("Model 3")
                .year(2024)
                .type(CarType.ELECTRIC)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.ELECTRIC)
                .pricePerDay(new BigDecimal("89"))
                .seats(5)
                .color("White")
                .licensePlate("ABC-1234")
                .imageUrl("https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800")
                .rating(4.9)
                .reviewCount(124)
                .totalQuantity(5)
                .availableQuantity(5)
                .description("Experience the future of driving with Tesla Model 3. Zero emissions, maximum performance.")
                .features(Arrays.asList("Autopilot", "Fast Charging", "Premium Sound", "Glass Roof"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(tesla);

        Car bmwX5 = Car.builder()
                .name("BMW X5")
                .brand("BMW")
                .model("X5")
                .year(2024)
                .type(CarType.SUV)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.DIESEL)
                .pricePerDay(new BigDecimal("120"))
                .seats(7)
                .color("Black")
                .licensePlate("XYZ-5678")
                .imageUrl("https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800")
                .rating(4.8)
                .reviewCount(89)
                .totalQuantity(3)
                .availableQuantity(3)
                .description("Luxury SUV with powerful performance and spacious interior. Perfect for family trips.")
                .features(Arrays.asList("Leather Seats", "Panoramic Roof", "360 Camera", "Navigation"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(bmwX5);

        Car mercedesC = Car.builder()
                .name("Mercedes C-Class")
                .brand("Mercedes")
                .model("C-Class")
                .year(2024)
                .type(CarType.SEDAN)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("95"))
                .seats(5)
                .color("Silver")
                .licensePlate("MER-9012")
                .imageUrl("https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800")
                .rating(4.7)
                .reviewCount(156)
                .totalQuantity(4)
                .availableQuantity(4)
                .description("Elegant and sophisticated sedan with cutting-edge technology.")
                .features(Arrays.asList("MBUX System", "Ambient Lighting", "Wireless Charging", "Heated Seats"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(mercedesC);

        Car porsche911 = Car.builder()
                .name("Porsche 911")
                .brand("Porsche")
                .model("911 Carrera")
                .year(2024)
                .type(CarType.SPORT)
                .transmission(TransmissionType.MANUAL)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("250"))
                .seats(2)
                .color("Red")
                .licensePlate("POR-9911")
                .imageUrl("https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800")
                .rating(5.0)
                .reviewCount(67)
                .totalQuantity(2)
                .availableQuantity(2)
                .description("The iconic sports car. Pure driving pleasure and timeless design.")
                .features(Arrays.asList("Sport Exhaust", "Carbon Ceramic Brakes", "Sport Chrono Package", "Launch Control"))
                .isActive(true)
                .availableBranches(Arrays.asList(downtown, midtown))
                .build();
        carRepository.save(porsche911);

        Car audiA4 = Car.builder()
                .name("Audi A4")
                .brand("Audi")
                .model("A4")
                .year(2024)
                .type(CarType.SEDAN)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.DIESEL)
                .pricePerDay(new BigDecimal("85"))
                .seats(5)
                .color("Gray")
                .licensePlate("AUD-4040")
                .imageUrl("https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800")
                .rating(4.6)
                .reviewCount(98)
                .totalQuantity(6)
                .availableQuantity(6)
                .description("Premium sedan combining comfort, technology, and efficiency.")
                .features(Arrays.asList("Virtual Cockpit", "Quattro AWD", "B&O Sound", "Matrix LED"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(audiA4);

        Car rangeRover = Car.builder()
                .name("Range Rover Sport")
                .brand("Land Rover")
                .model("Range Rover Sport")
                .year(2024)
                .type(CarType.SUV)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.HYBRID)
                .pricePerDay(new BigDecimal("180"))
                .seats(5)
                .color("Green")
                .licensePlate("RRS-2024")
                .imageUrl("https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?w=800")
                .rating(4.8)
                .reviewCount(45)
                .totalQuantity(3)
                .availableQuantity(3)
                .description("Luxury meets capability. Go anywhere in ultimate comfort.")
                .features(Arrays.asList("Terrain Response", "Air Suspension", "Meridian Audio", "Pixel LED"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(rangeRover);

        // Additional cars
        Car toyotaCamry = Car.builder()
                .name("Toyota Camry")
                .brand("Toyota")
                .model("Camry XSE")
                .year(2024)
                .type(CarType.SEDAN)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.HYBRID)
                .pricePerDay(new BigDecimal("65"))
                .seats(5)
                .color("Blue")
                .licensePlate("TOY-2024")
                .imageUrl("https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800")
                .rating(4.5)
                .reviewCount(203)
                .totalQuantity(8)
                .availableQuantity(8)
                .description("Reliable and fuel-efficient sedan. Perfect for everyday driving.")
                .features(Arrays.asList("Apple CarPlay", "Android Auto", "Safety Sense", "Keyless Entry"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(toyotaCamry);

        Car hondaCrv = Car.builder()
                .name("Honda CR-V")
                .brand("Honda")
                .model("CR-V Touring")
                .year(2024)
                .type(CarType.SUV)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("75"))
                .seats(5)
                .color("White")
                .licensePlate("HND-5050")
                .imageUrl("https://images.unsplash.com/photo-1568844293986-8c1a5b30120a?w=800")
                .rating(4.6)
                .reviewCount(178)
                .totalQuantity(6)
                .availableQuantity(6)
                .description("Spacious and versatile SUV with excellent fuel economy.")
                .features(Arrays.asList("Honda Sensing", "Wireless Charging", "Hands-Free Tailgate", "Heated Seats"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(hondaCrv);

        Car fordMustang = Car.builder()
                .name("Ford Mustang GT")
                .brand("Ford")
                .model("Mustang GT")
                .year(2024)
                .type(CarType.SPORT)
                .transmission(TransmissionType.MANUAL)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("150"))
                .seats(4)
                .color("Yellow")
                .licensePlate("MST-5050")
                .imageUrl("https://images.unsplash.com/photo-1584345604476-8ec5e12e42dd?w=800")
                .rating(4.9)
                .reviewCount(112)
                .totalQuantity(3)
                .availableQuantity(3)
                .description("American muscle car with thrilling V8 performance.")
                .features(Arrays.asList("V8 Engine", "Track Apps", "Launch Control", "Brembo Brakes"))
                .isActive(true)
                .availableBranches(Arrays.asList(downtown, midtown))
                .build();
        carRepository.save(fordMustang);

        Car jeepWrangler = Car.builder()
                .name("Jeep Wrangler")
                .brand("Jeep")
                .model("Wrangler Rubicon")
                .year(2024)
                .type(CarType.SUV)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("110"))
                .seats(5)
                .color("Orange")
                .licensePlate("JEP-4X4")
                .imageUrl("https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800")
                .rating(4.7)
                .reviewCount(89)
                .totalQuantity(4)
                .availableQuantity(4)
                .description("Legendary off-road capability with iconic design.")
                .features(Arrays.asList("4x4 System", "Removable Top", "Trail Rated", "Rock-Trac 4WD"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(jeepWrangler);

        Car lexusEs = Car.builder()
                .name("Lexus ES 350")
                .brand("Lexus")
                .model("ES 350")
                .year(2024)
                .type(CarType.LUXURY)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("130"))
                .seats(5)
                .color("Pearl White")
                .licensePlate("LEX-3500")
                .imageUrl("https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800")
                .rating(4.8)
                .reviewCount(67)
                .totalQuantity(3)
                .availableQuantity(3)
                .description("Refined luxury sedan with whisper-quiet ride.")
                .features(Arrays.asList("Mark Levinson Audio", "Adaptive Suspension", "Head-Up Display", "Semi-Aniline Leather"))
                .isActive(true)
                .availableBranches(Arrays.asList(downtown, airport))
                .build();
        carRepository.save(lexusEs);

        Car vwGolf = Car.builder()
                .name("Volkswagen Golf GTI")
                .brand("Volkswagen")
                .model("Golf GTI")
                .year(2024)
                .type(CarType.SEDAN)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("70"))
                .seats(5)
                .color("Red")
                .licensePlate("VWG-8080")
                .imageUrl("https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800")
                .rating(4.5)
                .reviewCount(145)
                .totalQuantity(5)
                .availableQuantity(5)
                .description("Hot hatch with perfect balance of fun and practicality.")
                .features(Arrays.asList("Digital Cockpit", "Sport Suspension", "Plaid Seats", "Performance Monitor"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(vwGolf);

        Car hyundaiTucson = Car.builder()
                .name("Hyundai Tucson")
                .brand("Hyundai")
                .model("Tucson Limited")
                .year(2024)
                .type(CarType.SUV)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.HYBRID)
                .pricePerDay(new BigDecimal("68"))
                .seats(5)
                .color("Dark Gray")
                .licensePlate("HYU-2024")
                .imageUrl("https://images.unsplash.com/photo-1630990325617-318cfb2ba3b4?w=800")
                .rating(4.4)
                .reviewCount(156)
                .totalQuantity(7)
                .availableQuantity(7)
                .description("Modern design with advanced tech and hybrid efficiency.")
                .features(Arrays.asList("Blind Spot View", "Remote Smart Parking", "Bose Audio", "Panoramic Roof"))
                .isActive(true)
                .availableBranches(allBranches)
                .build();
        carRepository.save(hyundaiTucson);

        Car chevroletSuburban = Car.builder()
                .name("Chevrolet Suburban")
                .brand("Chevrolet")
                .model("Suburban Premier")
                .year(2024)
                .type(CarType.SUV)
                .transmission(TransmissionType.AUTOMATIC)
                .fuel(FuelType.PETROL)
                .pricePerDay(new BigDecimal("140"))
                .seats(8)
                .color("Black")
                .licensePlate("CHV-8888")
                .imageUrl("https://images.unsplash.com/photo-1612544448445-b8232cff3b6c?w=800")
                .rating(4.6)
                .reviewCount(78)
                .totalQuantity(3)
                .availableQuantity(3)
                .description("Full-size SUV with maximum space for family and cargo.")
                .features(Arrays.asList("3rd Row Seating", "Rear Entertainment", "Power Folding Seats", "Trailering Package"))
                .isActive(true)
                .availableBranches(Arrays.asList(airport, downtown))
                .build();
        carRepository.save(chevroletSuburban);

        // Create sample notifications for the sample user
        createSampleNotifications(sampleUser, tesla);

        System.out.println("========================================");
        System.out.println(" Sample data initialized successfully!");
        System.out.println("========================================");
        System.out.println(" Manager:  admin@autora.com / admin123 (General Manager)");
        System.out.println(" Manager:  manager@autora.com / manager123 (Branch Manager)");
        System.out.println(" Employee: ahmad@autora.com / employee123");
        System.out.println(" Employee: khaled@autora.com / employee123");
        System.out.println(" Employee: mohammed@autora.com / employee123");
        System.out.println(" Customer: john@example.com / password123");
        System.out.println("========================================");
    }

    private void createSampleNotifications(User user, Car sampleCar) {
        // Welcome notification
        Notification welcome = Notification.builder()
                .user(user)
                .title("Welcome to Autora!")
                .message("Thank you for joining Autora Car Rental. Explore our premium fleet and book your perfect ride today!")
                .type(NotificationType.GENERAL)
                .isRead(false)
                .build();
        notificationRepository.save(welcome);

        // Special offer notification
        Notification offer = Notification.builder()
                .user(user)
                .title("Weekend Special: 20% Off!")
                .message("Book any car this weekend and get 20% off! Use code WEEKEND20 at checkout. Limited time offer.")
                .type(NotificationType.SPECIAL_OFFER)
                .isRead(false)
                .build();
        notificationRepository.save(offer);

        // New car notification
        Notification newCar = Notification.builder()
                .user(user)
                .title("New Arrival: Tesla Model 3")
                .message("Experience the future of driving! Our new Tesla Model 3 is now available for booking at $89/day.")
                .type(NotificationType.NEW_CAR)
                .referenceId(sampleCar.getId())
                .isRead(false)
                .build();
        notificationRepository.save(newCar);

        // Reminder notification
        Notification reminder = Notification.builder()
                .user(user)
                .title("Complete Your Profile")
                .message("Add a profile photo and verify your driver's license to unlock exclusive member benefits!")
                .type(NotificationType.GENERAL)
                .isRead(false)
                .build();
        notificationRepository.save(reminder);
    }
}
