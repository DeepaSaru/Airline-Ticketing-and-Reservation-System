# Airline-Ticketing-and-Reservation-System

The objective of this project is to design and implement a secure and efficient airport ticketing system that supports the end-to-end process of ticket issuance. The workflow begins with employee authentication, where staff log in using unique credentials. Role-based access control is enforced, distinguishing between Ticketing Staff and Ticketing Supervisors to ensure appropriate authorization levels and system security.

Following authentication, the reservation module enables employees to search and manage bookings using the Passenger Name Record (PNR). This module supports retrieval of passenger details, validation of booking status, and updates where required. To issue a ticket, the employee reviews critical data, including flight number, schedule, and seat assignment. Upon confirmation, the system generates an electronic boarding number, which is securely linked to the employee’s ID to maintain traceability and audit compliance.

Fare computation forms a core system component. The process begins with the base fare and incorporates additional charges such as excess baggage, premium seating, or upgraded meals. This ensures accuracy in pricing and transparency in billing. Data integrity is maintained by establishing explicit relationships between key entities—flights, passengers, tickets, and ancillary services—ensuring consistency across transactions and facilitating reporting.

For implementation, a normalized relational database schema is recommended to reflect real-world ticketing processes. SQL scripts will be developed for authentication, reservation queries, fare calculation, ticket issuance, and referential integrity checks. This structured approach ensures scalability, reliability, and compliance with data management standards.

In summary, the system design integrates authentication, reservation management, and fare calculation within a robust database framework. By enforcing security, maintaining data integrity, and streamlining operational workflows, the solution provides an effective platform for managing airport ticketing operations.
