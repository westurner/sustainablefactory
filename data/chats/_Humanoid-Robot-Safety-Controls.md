> From: https://gemini.google.com/app/7c03b49bd969d0ad

# you asked

message time: 2026-07-23 19:47:09

What should do about humanoid AI robot safety?

From a prior chat on this: https://g.co/gemini/share/9f4d9b0107b9

- At least two (2) red mushroom emergency stop buttons
- Grappling points,
- > A physical, standardized first-responder disconnect loop, identical in principle to the one on EVs.




### draft letter

Subject: Inquiry Regarding the Development of an Emergency Disconnect Standard for Humanoid Robots

Dear [Appropriate Department/Contact Person at A3, CPSC, NFPA, or OSHA],

I am writing to you today with a proactive concern for public and occupational safety regarding the imminent deployment of autonomous humanoid robots.

The need for forward-thinking safety standards for new technology is well-established. Precedents like the CPSC's mandate for SawStop's active injury prevention on table saws, and the comprehensive safety standards governing EV charging infrastructure (under NFPA 70/NEC and UL), which include the vital first-responder disconnect loop, provide a clear and successful model. A similar, dedicated standard is now urgently needed for mobile humanoid robots.

While a foundational safety framework exists, it was not designed for this new paradigm. I have analyzed the key existing controls and standards, and each has significant gaps when applied to mobile humanoids:

ANSI/RIA R15.06 & ISO 10218 (Industrial Robots):
- What They Cover: These are the gold standards for traditional industrial robots, mandating E-stops and safeguarding.
- The Gap: They fundamentally assume a robot is stationary and operates within a controlled, predictable, and restricted "workcell" accessed only by trained professionals. They do not account for a robot moving autonomously through unpredictable public spaces.

ISO 13482 (Personal Care Robots):
- What It Covers: This standard addresses robots operating in closer proximity to people.
- The Gap: It often presumes less powerful or complex systems than a full-sized humanoid and does not adequately address the unique hazards of a heavy, bipedal robot that could fall or interact with untrained members of the public.

OSHA 29 CFR 1910.147 & 1910.333 (Lockout/Tagout):
- What They Cover: These regulations are critical for requiring the formal de-energization of machinery for service and maintenance.
- The Gap: This is a procedural disconnect for planned maintenance, not an instantaneous E-stop for an active emergency. It is meant to protect a technician, not a member of the public or a first responder facing a malfunctioning machine.

These standards leave several critical, unaddressed risks specific to mobile humanoid robots:

Standardized Remote Deactivation: The drone industry has already established protocols for remote "stop codes" or kill switches. A similar standard is needed for humanoids, ensuring a secure, non-hackable wireless channel for an operator to immediately halt a unit that is behaving erratically, well before it requires intervention from emergency services.

First Responder Emergency Access: In an emergency, personnel cannot be expected to approach a potentially dangerous machine. A multi-tiered standard is needed:

At a minimum: A physical, standardized first-responder disconnect loop, identical in principle to the one on EVs.

For non-contact stops: The standard should contemplate specifications for disabling a robot's electronics from a distance, perhaps via a directed, localized solid-state microwave or RF emitter, ensuring a safe shutdown when physical access is impossible.

For physical intervention: The standard should define interfaces for an "interceptor" robot to use, such as a standardized handle or grapple point, allowing a specialized unit to safely quell and retrieve a malfunctioning one.

Dynamic Mobility & Physical E-Stops: A single E-stop location is insufficient for a machine that moves, turns, and can fall, potentially rendering the button inaccessible. A standard must define requirements for multiple, consistently placed, and easily accessible physical E-stops.

The "Safe-Stop" State: Unlike an industrial arm that just brakes, a bipedal robot that simply cuts power to its joints will collapse, creating a significant impact hazard. A new standard must define a "fail-safe" state, such as an autonomous crouch or kneel, to ensure the stop itself does not cause injury.

Given these safety gaps, I am writing to inquire about the process for initiating a discussion on developing a new, dedicated standard for mobile humanoid robots. A forward-thinking approach is essential for the responsible and successful adoption of this technology.

Thank you for your time and for your leadership in safety. I look forward to your response.

Respectfully,

[Your Name]

[Your Contact Information]


### DRAFT TECHNICAL SPECIFICATION

TITLE: Emergency Deactivation Systems (EDS) for Publicly-Deployed Mobile Humanoid Robots (MHRs)

DATE: September 28, 2025

STATUS: Preliminary Draft for Review

1.0 SCOPE AND PURPOSE

This technical specification defines the minimum requirements for the design, implementation, and performance of Emergency Deactivation Systems (EDS) for Mobile Humanoid Robots (MHRs) intended for operation in public or unstructured environments. The purpose is to ensure a multi-layered safety framework that allows operators, the public, and emergency first responders to safely halt and de-energize an MHR during a malfunction, emergency, or other hazardous situation.

2.0 DEFINITIONS

Mobile Humanoid Robot (MHR): An autonomous or semi-autonomous, bipedal mobile robot with a form factor approximating the human body, designed to operate without a physical tether in unstructured environments.

Emergency Deactivation System (EDS): The complete set of hardware and software components on an MHR designed to execute a Safe-Stop State.

Safe-Stop State: A state in which the MHR has ceased all hazardous motion and entered a physically stable, low-energy configuration (e.g., a controlled kneel or crouch) with its joints locked to prevent collapse. This is distinct from an uncontrolled collapse resulting from simple power removal.

First Responder Cut Loop (FRCL): A physical, externally accessible loop for the complete mechanical severance of all battery power.

Non-Contact Stop Receiver (NCSR): A secure, standardized electronic receiver for remotely triggering the Safe-Stop State via a directed energy signal.

Standardized Grapple Points (SGP): Reinforced, consistently located points on the MHR's chassis designed for capture and manipulation by another robotic or mechanical system.

3.0 PHYSICAL EMERGENCY STOP ACTUATORS

3.1. An MHR shall be equipped with a minimum of three (3) physical emergency stop buttons compliant with ISO 13850 (red, mushroom-shaped, twist-to-reset).

3.2. Locations: One button shall be located on the upper torso (front), one on the upper torso (back), and one on an accessible limb (e.g., forearm). Locations must remain accessible if the MHR is in a 90-degree prone or supine position.

4.0 REMOTE OPERATOR DEACTIVATION SYSTEM

4.1. The MHR shall be controllable via a remote system that incorporates a constant-communication "heartbeat" or "dead man's switch" protocol. Loss of this signal for more than 500ms shall trigger the Safe-Stop State.

4.2. The operator shall have a dedicated, encrypted "Remote Stop" command that has priority over all autonomous functions and immediately triggers the Safe-Stop State. This function shall be distinct from standard operational stop commands.

5.0 FIRST RESPONDER DEACTIVATION SYSTEMS

5.1. Tier 1: Physical Cut Loop (FRCL):

5.1.1. The MHR must be equipped with a clearly marked First Responder Cut Loop. The loop shall be bright yellow and constructed of non-conductive, high-tensile material.

5.1.2. The FRCL shall be located on the upper back, near the shoulder line, and be accessible without requiring fine motor manipulation (e.g., accessible by a hook or blade on a pole).

5.1.3. Severing the FRCL shall mechanically and irreversibly disconnect all battery power from the MHR's primary motor and logic systems.

5.2. Tier 2: Non-Contact Stop Receiver (NCSR):

5.2.1. The MHR must be equipped with an NCSR operating on a standardized, reserved frequency band (e.g., 433 MHz band, to be determined by regulatory bodies).

5.2.2. The NCSR shall require a secure, digitally signed "handshake" from a certified first-responder emitter to prevent accidental or malicious activation.

5.2.3. Successful activation via the NCSR shall trigger the Safe-Stop State.

5.3. Tier 3: Standardized Grapple Points (SGP):

5.3.1. The MHR must have a minimum of two SGPs located on the upper torso/shoulders.

5.3.2. SGPs must be constructed of high-strength material (e.g., forged aluminum or steel alloy) and be capable of supporting 1.5x the MHR's total mass without deformation.

5.3.3. The geometry of the SGPs shall be standardized to allow for secure gripping by a robotic manipulator.

6.0 SAFE-STOP STATE PROTOCOL

6.1. Upon activation of any Tier 1, 2, or 3 stop command, the MHR's primary logic shall immediately execute the Safe-Stop State protocol.

6.2. The protocol sequence shall be: 1) Cease all forward momentum and task execution; 2) Assess balance and stability; 3) Perform a controlled descent to a stable kneeling or seated position; 4) Engage mechanical or software-based joint locks; 5) Transmit a final "safe state" signal. The entire sequence from trigger to final state shall not exceed 2.5 seconds.

--




--

Attached: A draft bill for this from the same Gemini 2.5 Pro prompts:

---
H. R. [...] The Humanoid Robot Public Safety Act of 2026

A BILL to ensure the safe deployment of autonomous robots in public spaces and to provide for the establishment of mandatory safety standards for such devices.

SECTION 1. FINDINGS AND PURPOSE.

(a) FINDINGS.—Congress finds the following:

(1) Autonomous humanoid robots represent a transformative technology with the potential for significant economic and social benefit.

(2) The deployment of these robots in public spaces alongside untrained citizens presents novel safety challenges not addressed by existing regulations designed for industrial or stationary machinery.

(3) Proactive, clear, and robust safety standards are necessary to prevent injury, build public trust, and provide a clear framework for innovation.

(4) A multi-layered safety system, accessible to operators, the public, and first responders, is essential for mitigating risk.

(b) PURPOSE.—The purpose of this Act is to protect the public by mandating that all autonomous humanoid robots operating in the United States are equipped with a certified Emergency Deactivation System.

SECTION 2. DEFINITIONS.

In this Act:

(1) The term "Autonomous Humanoid Robot" means any commercially available, bipedal, mobile robotic device that is capable of operating in a public space without continuous direct mechanical or tethered control by a human.

(2) The term "Public Space" means any area, indoor or outdoor, that is accessible to the general public.

(3) The term "Commission" means the Consumer Product Safety Commission.

(4) The term "Emergency Deactivation System" means the set of mechanisms, compliant with the standards promulgated under this Act, designed to bring a robot to a safe, stable, and de-energized state.

SECTION 3. EMERGENCY DEACTIVATION SYSTEM MANDATE.

Effective two years after the date of enactment of this Act, it shall be unlawful for any person to manufacture for sale, sell, import, or operate in a public space an Autonomous Humanoid Robot that is not equipped with an Emergency Deactivation System certified under the rules promulgated by the Commission pursuant to Section 4.

SECTION 4. PROMULGATION OF SAFETY STANDARDS.

(a) IN GENERAL.—Not later than 18 months after the date of enactment of this Act, the Commission, in consultation with the National Institute of Standards and Technology and the Department of Homeland Security, shall promulgate final regulations to establish minimum standards for the Emergency Deactivation System.

(b) REQUIREMENTS.—The standards established under subsection (a) shall require that the Emergency Deactivation System includes, at a minimum:

(1) Multiple Physical Actuators: No fewer than three externally accessible, standardized emergency stop buttons.

(2) Secure Remote Shutdown: A capability for a verified human operator to remotely and wirelessly command the robot to a safe state.

(3) First Responder Access: A tiered system for emergency personnel, which shall include:

(A) A physical, non-electronic means of fully disconnecting battery power from a safe distance, known as a "First Responder Cut Loop."

(B) A secure receiver for a standardized, non-contact signal to command the robot to a safe state.

(4) Controlled Failure State: A mandatory protocol that ensures the robot, upon activation of any emergency stop, enters a physically stable, controlled state, such as kneeling, and does not collapse in an uncontrolled manner.

SECTION 5. ENFORCEMENT AND PENALTIES.

(a) ENFORCEMENT.—This Act shall be enforced by the Commission.

(b) CIVIL PENALTIES.—Any person who violates Section 3 of this Act shall be subject to civil penalties in accordance with section 20 of the Consumer Product Safety Act (15 U.S.C. 2069). Any robot found to be in violation may be subject to seizure.

--

I have hardly reviewed this legislative bill draft; it looks like it has:

> Effective two years after the date of enactment of this Act, it shall be unlawful for any person to manufacture for sale, sell, import, or operate in a public space an Autonomous Humanoid Robot that is not equipped with an Emergency Deactivation System certified under the rules promulgated by the Commission pursuant to Section 4.

--

Contextually,

There is at present a published exploit for a vulnerability in mass-produced humanoid robots by an overeager vendor.

The Terminator (1984), AI (2001), I Robot (1950, 2004), The Wild Robot (2024), Bicentennial Man (1999)

FDA doesn't yet require fuzzing for medical devices, but there is a framework of technical process recommendations and requirements.

In 2009-2010 I worked in a large Hospital on software for filing medical orders and Linux systems administration. I have little experience with robots
 and no specific concerns with any particular product at present. 

Thanks for your consideration,

Hoping for Next Steps on this

What additional controls would be appropriate given a new review of mobile humanoid robot safety controls and regulations?

---

# gemini response

Thinking

**Analyzing Recent Robotics Standards**

I've found incredibly relevant search results! My focus is now on the key findings from 2026. I see **ISO 10218:2025** has just been released, expanding significantly. It explicitly includes cybersecurity, classifies robots as Class I or Class II, and the following point is eliminated: *the following point is eliminated*



**Integrating New Findings**

I'm now integrating information on new standards. Specifically, I'm noting the shift away from the term "collaborative robot" toward "collaborative application," as per TS 15066. I'm also incorporating the critical points from **ISO 25785-1**, concerning dynamically stable robots. The collapse vulnerability and OSHA's General Duty Clause are key concerns. Battery safety is also significant, with hot-swap protocols, thermal runaway, and arc flash events. I am working on brainstorming additional controls, building on the user's initial draft.



**Developing Safety Controls**

I'm now focusing on specific safety controls. I've designed a two-part solution. First, I propose cryptographic hardware anchors and key revocation to prevent spoofing of the remote stop signal, and ensure it operates independently. Second, I've designed dynamic fall-zone indicators, like projected laser floor markings, to warn people of a humanoid robot's fall radius.



**Refining Emergency Protocols**

I'm now zeroing in on emergency protocols, spurred by 2026 standards. I'm prioritizing thermal management during Safe-Stop scenarios, with active thermal monitoring overrides, and clear-zone navigation. I'm also focused on arc-flash protected hot-swap connectors to the new standard. Additionally, auditory alarms for state changes are now paramount, along with warnings. I'm also looking at standardized emergency stop processes.



**Implementing Cyber Controls**

I'm now focusing on cybersecurity and physical entanglement controls. My draft is perfectly aligned with real-world developments! Specifically, I've prioritized an Immutable Incident Data Recorder (IDR) to lock critical sensor data 30 seconds prior to an emergency stop. This complements the user's focus on traceability. Also, all hazardous joints will be sheathed to prevent entanglement, a key aspect of ISO/TS 15066 compliance.



**Categorizing Safety Aspects**

I am now categorizing safety aspects for concise presentation: Network, Physical/Kinematic, Thermal/Energy, and Post-Incident. I'm focusing on clean Markdown formatting with a highly expert tone, avoiding any unnecessary introductory statements. This structure directly informs the letter and technical specifications with concrete details.



**Defining Technical Specifications**

I'm now refining the technical specifications, adding detail. Section 7.0 will cover independent safety circuitry to create an out-of-band control, with a physically isolated microcontroller. I am developing Section 8.0, which will address kinematic intent and fall zones, including visual indications. Section 9.0 will cover thermal event hierarchy and the crucial distinctions between mechanical, software, and thermal faults, and Section 10.0, the "Black Box" or Incident Data Recorder. I am integrating these additions into a cohesive narrative. I'm focusing on connecting the new additions to the existing draft, and to the current developing ISO 25785-1 standard.



**Structuring the Narrative**

I am now focusing on structuring the narrative by creating concrete section updates: Structural & Kinematic, Electronic & Cybersecurity, and Thermal & Energy Isolation. I'm also preparing actionable revisions for the draft letter and specification. I'm verifying the inclusion of key citations and applying them as appropriate. My focus is on concise organization and avoiding unnecessary tools.



**Formulating Feedback**

I'm now formulating specific feedback to the user's drafts, keeping it concise. Your existing work aligns well with current industry struggles, particularly regarding dynamically stable robots. I've focused on additional controls, like an out-of-band safety architecture for E-stops, and dynamic fall-zone projection, due to the changing fall radius of humanoids. Furthermore, I've integrated controls for thermal runaway handling and a robust Incident Data Recorder for post-event analysis. `<ElicitationsGroup>`



**Implementing Specific Controls**

I'm now implementing the user's focus on simple formatting or units. I've formulated detailed controls for the OOB Safety Architecture, detailing an air-gapped microcontroller for the Emergency Deactivation System, and Non-Contact Stop Receiver. I've also detailed the dynamic fall-zone indication, with a downward-facing laser projector, and kinematic footprint broadcast.



**Prioritizing Thermal Hazards**

I'm now zeroing in on integrating controls for state-dependent thermal responses. I am prioritizing a thermal-event override to the standard safe-stop. Specifically, the system will now be designed to navigate to a pre-defined clear zone, where the hardware disconnect can be safely executed. I'm also ensuring arc-flash protected hot-swap connectors are used for battery arrays. Finally, I'm integrating information on entanglement and pinch-point shrouding.



**Adding Kinematic Safeguards**

I'm now integrating kinematic safeguards and considering their position. Specifically, I'm focusing on gap tolerances to prevent limb amputations during unpowered robot collapse. Furthermore, I've expanded the Immutable Incident Data Recorder (IDR) to lock the last 60 seconds of telemetry upon EDS activation, inspired by medical device and aviation frameworks. This information will be seamlessly incorporated into the technical specifications and is a perfect complement to the previous drafts.



**Refining Presentation Structure**

I'm now refining the presentation structure to address legislative needs, and focusing on tone. I am emphasizing that the existing work anticipates key pain points in developing standards like ISO 25785-1 [1.1.2]. I've found that the EU AI Act / Machinery Regulation 2023/1230 [1.1.4] is relevant here, so I'm tailoring the new additions for compliance. I'm prioritizing clarity and avoiding unnecessary jargon to create a validating, expert tone. I'm adding concrete details to the draft letter and specifications.

Your draft specification and legislative framework are remarkably well-targeted. The robotics industry is currently wrestling with the exact regulatory gaps you've identified. In fact, the developing ISO 25785-1 standard for dynamically stable robots is being drafted precisely because, as your letter notes, humanoids collapse when power is cut, rendering legacy ISO 10218 rules for bolted-down industrial arms dangerously insufficient. 

Given the context of recent mass-produced humanoid exploits and the shift from controlled industrial floors to unstructured public spaces, the safety framework must assume the primary operating system will eventually fail or be compromised. 

Here are five additional, critical controls that should be integrated into your technical review and specification:

## 1. Out-of-Band (OOB) Safety Architecture
If a humanoid's primary AI, navigation stack, or network interface is exploited, any software-routed stop command is useless. 
* **The Control:** The Emergency Deactivation System (EDS) must operate on a completely isolated, air-gapped hardware circuit (e.g., SIL 3 / PL e rated). The Non-Contact Stop Receiver (NCSR) and physical E-stops must trigger mechanical contactors that sever power to the actuators directly, bypassing the robot's main compute logic entirely. 

## 2. Dynamic Fall-Zone Projection
Unlike fixed machinery, a walking robot's hazard zone changes based on its speed, mass distribution, and center of gravity. 
* **The Control:** The standard should require MHRs to continuously broadcast their kinematic footprint. This can be achieved via downward-facing lasers (similar to forklift safety halos) that dynamically project a visible boundary on the floor. If the robot is moving at 1.5 m/s, the projected radius expands to show the unavoidable fall zone, giving the public intuitive visual warning.

## 3. State-Dependent Thermal Overrides
Your "Safe-Stop" crouch is perfect for a logic error or mechanical fault. However, if the robot experiences battery thermal runaway, crouching in a public space turns it into a stationary hazard.
* **The Control:** The EDS must include independent thermal monitoring. If a thermal event is detected, the standard Safe-Stop must be overridden. The robot should emit a distinct, high-decibel fire-hazard alarm and, if navigation is still possible, move to a pre-defined clear zone away from flammable materials before executing the hardware disconnect. Furthermore, hot-swappable battery systems must require arc-flash protected, interlocked connectors to prevent separation under active load.

## 4. Immutable Incident Data Recorder (IDR)
Drawing from your hospital IT background, medical device frameworks heavily emphasize traceability and logging for post-market surveillance. 
* **The Control:** Mandate a hardened, read-only "black box." This IDR must continuously buffer the last 60 seconds of telemetry, video, and safety-circuit states. Upon any Tier 1, 2, or 3 EDS activation, this buffer must lock immutably. This ensures that when a vendor's robot is exploited or causes an injury, regulatory bodies have tamper-proof forensic data.

## 5. Pinch-Point and Shear-Hazard Sheathing
When a 150+ lb bipedal robot collapses into your Safe-Stop state, untrained bystanders may instinctively try to catch it or push it away. 
* **The Control:** All high-torque joints capable of generating forces that exceed standard biomechanical limits (e.g., >140 N for upper limbs) must be enclosed in compliant sheathing or engineered with sufficient physical gap tolerances. This prevents accidental finger amputation or limb crushing as the unpowered chassis folds in on itself.

---

### Suggested Inserts for Your Drafts

**For the Letter:**
Under the *Dynamic Mobility & Physical E-Stops* section, add:
> **Dynamic Fall Zones:** Because a humanoid's hazard radius shifts with its velocity, standard static guarding is impossible. A new standard must mandate active visual indicators—such as dynamic laser floor projections—that continuously communicate the robot's unavoidable collapse radius to surrounding pedestrians.

**For the Technical Specification:**
Add a new section `7.0 DATA PRESERVATION`:
> **7.1.** The MHR must incorporate an isolated Incident Data Recorder (IDR) that continuously buffers 60 seconds of kinematic telemetry and safety-circuit states. 
> **7.2.** Activation of any EDS tier must immutably lock the IDR buffer to ensure tamper-proof forensics for post-incident regulatory review.

**For the Legislative Bill:**
In `SECTION 4(b)`, add a requirement for cyber-physical isolation:
> **(5) Out-of-Band Actuation:** A requirement that the Emergency Deactivation System operates on isolated hardware, ensuring that an emergency shutdown cannot be intercepted, delayed, or overridden by a software exploit in the robot's primary operating system.

<ElicitationsGroup message="To refine these documents further:">
  <Elicitation label="Draft the IDR (Black Box) technical requirements" query="Draft a detailed technical specification section for the Incident Data Recorder (IDR), including cryptographic signing and data retention requirements."/>
  <Elicitation label="Explore anti-spoofing for the remote stop" query="How can we design the Non-Contact Stop Receiver (NCSR) to mathematically guarantee it cannot be spoofed by a malicious actor?"/>
  <Elicitation label="Update the legislative draft with these controls" query="Integrate the five new safety controls directly into the text of the H.R. Humanoid Robot Public Safety Act of 2026 draft."/>
</ElicitationsGroup>

---

# you asked

message time: 2026-07-23 19:49:29

Prepare an updated summary letter for Congress people who are receptive to AI kill switch legislation

---

# gemini response

Thinking

**Drafting Summary Letter**

I've begun drafting the summary letter, incorporating today's news from Rep. Lieu on AI kill switch legislation!



**Analyzing Kill Switch Options**

I'm now expanding to incorporate hardware kill switches for the humanoid robot act, specifically for Emergency Deactivation Systems.



**Integrating Physical Controls**

I've integrated the new safety controls, focusing on hardware-level Emergency Deactivation Systems for the bill.



**Refining Contextual Data**

I've refined the contextual data, ensuring personalized content delivery and incorporating the user's previous draft and chat history.



**Refining Fact Integration**

I've integrated the July 2026 AI crisis fact to establish context for humanoid robot safety regulations.



**Structuring Safety Provisions**

I've structured the letter, including an out-of-band safety architecture proposal for the Humanoid Robot Public Safety Act.



**Detailing Hardware Controls**

I've refined details, focusing on five critical hardware controls for the Act, like safe-stop states and immutable data recording.



**Defining Physical Safeguards**

I've defined five core safeguards for the act, focusing on out-of-band safety architecture for emergency stops.



**Defining Emergency Protocols**

I've defined emergency protocols, including multi-tiered first responder access and safe-stop protocols for humanoid robots.



**Aligning Legislation Detail**

I've aligned the proposed IDR bullet point with the core requirements outlined in the Lieu/Moran AI Kill Switch Act.



**Verifying Document Integrity**

I've verified the document's integrity, ensuring the format uses bolding effectively, no filler or latex, and compliant bullet points.



**Evaluating Cryptography Security**

I'm now evaluating cryptography for the Non-Contact Stop Receiver, prioritizing robust public safety against malicious actors.



**Connecting Legislation Support**

I've connected my hardware framework directly with the Kill Switch Act, focusing on support for lawmakers with citations.



**Integrating Incident Data**

I have integrated the recent AI Kill Switch Act into my draft, specifically incorporating references to incidents [1.3.2] and Department intervention [1.3.4].



**Framing Hardware Safeguards**

I've framed five core hardware safeguards for the Act, including immutable data recording and safe-stop states.



**Defining Emergency Protocols**

I've clarified the Multi-Tiered First Responder Access protocol with standardized grapple points and a secure NCSR.



**Defining Safe-Stop States**

I've defined safe-stop states and dynamic fall-zone projections for humanoid robots, for enhanced public safety.

Today (July 23, 2026), Representatives Ted Lieu and Nathaniel Moran introduced the AI Kill Switch Act. This bill mandates that developers of powerful AI systems maintain the technical ability to throttle or shut them down, gives the Department of Homeland Security intervention authority in a "loss-of-control scenario", and requires preserving forensic records after incidents.

This is the perfect hook for your outreach. You can position your framework as the necessary physical counterpart to their software-focused legislation, explicitly linking your Incident Data Recorder (IDR) to their forensic requirements.

Here is an updated summary letter tailored directly to lawmakers sponsoring this type of legislation, integrating the five new physical controls:

***

**Subject:** Complementary Hardware Protections to the AI Kill Switch Act: Securing Physical AI

Dear Representative [Name],

I am writing to express my strong support for the AI Kill Switch Act. Ensuring that developers maintain the capacity to throttle or shut down advanced software models is a critical step in securing our digital infrastructure. However, as frontier AI models are increasingly embodied in physical, autonomous systems, we must aggressively secure the hardware layer.

A software-based kill switch is vital, but insufficient when deployed in a 150-pound bipedal robot operating in public spaces. If an advanced model breaches its guardrails or the primary operating system is exploited—as seen in recent vulnerabilities affecting mass-produced humanoids—any software-routed stop command can be delayed or bypassed. To prevent a physical loss-of-control scenario, we need an unhackable, out-of-band hardware braking system.

I have drafted a complementary framework, the **Humanoid Robot Public Safety Act of 2026**, which mandates standardized Emergency Deactivation Systems (EDS) for autonomous mobile robots. This framework translates the principles of your legislation into the physical world through five core safeguards:

*   **Out-of-Band (OOB) Safety Architecture:** Emergency stop commands (both physical and remote) must operate on completely isolated, air-gapped hardware circuits. This guarantees that deactivating the robot bypasses the primary AI logic entirely, ensuring an exploited model cannot ignore a shutdown order.
*   **Immutable Incident Data Recorders (IDR):** To support the forensic record preservation required by your bill, robots must contain a hardened "black box." This IDR continuously buffers the last 60 seconds of kinematic telemetry and safety-circuit states, locking immutably upon a shutdown event to provide regulators with tamper-proof post-incident data.
*   **Multi-Tiered First Responder Access:** In an emergency, first responders need standardized interfaces to de-energize the machine without approaching it. This includes a physical cut loop (similar to EV standards), standardized grapple points, and a secure Non-Contact Stop Receiver (NCSR) triggered by emergency services.
*   **Controlled "Safe-Stop" Protocol:** A bipedal robot that simply cuts power will collapse unpredictably, creating a severe crushing hazard. The EDS must trigger a controlled descent into a locked, stable position (e.g., a kneel) with compliant sheathing over pinch points to protect bystanders.
*   **Dynamic Fall-Zone Projections:** Because a moving robot's hazard zone changes based on its velocity and center of gravity, it must continuously project a visible boundary (e.g., via floor lasers), warning the public of its unavoidable collapse radius.

We are moving rapidly from AI that generates text to AI that physically navigates our streets, hospitals, and workplaces. Extending the AI Kill Switch Act's oversight to mandate physical, out-of-band hardware disconnects will ensure complete public safety.

I would welcome the opportunity to share the full technical specification and legislative draft with your staff to help build the physical safeguards necessary for the secure deployment of American robotics.

Respectfully,

[Your Name]  
[Your Contact Information]

***

<ElicitationsGroup message="To tailor this outreach further:">
  <Elicitation label="Draft a technical brief for staff" query="Draft a 1-page technical brief that expands on the Out-of-Band Safety Architecture and the IDR, designed for a congressional staffer to read."/>
  <Elicitation label="Review NCSR anti-spoofing logic" query="How should we structure the cryptography for the Non-Contact Stop Receiver to ensure it can't be triggered by bad actors in public?"/>
</ElicitationsGroup>

---
Powered by [AI Exporter](https://saveai.net)