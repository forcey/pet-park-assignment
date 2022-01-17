//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

enum AnimalType {
    None,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
}

enum Gender {
    Male,
    Female
}

struct Borrower {
    bool visited;
    Gender gender;
    uint8 age;
    AnimalType borrowedAnimal;
}

contract PetPark {
    address owner;

    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => Borrower) borrowerRegistry;

    event Added(AnimalType animal, uint256 count);
    event Borrowed(AnimalType animal);
    event Returned(AnimalType animal);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }

    modifier validAnimal(AnimalType animal) {
        require(animal != AnimalType.None, "Invalid animal");
        _;
    }
    modifier validAnimalButMessageIsSomehowDifferent(AnimalType animal) {
        require(animal != AnimalType.None, "Invalid animal type");
        _;
    }

    function add(AnimalType animal, uint256 count)
        public
        onlyOwner
        validAnimal(animal)
    {
        animalCounts[animal] += count;
        emit Added(animal, count);
    }

    function borrow(
        uint8 age,
        Gender gender,
        AnimalType animal
    ) public validAnimalButMessageIsSomehowDifferent(animal) {
        require(age > 0, "Invalid Age");
        Borrower storage borrower = borrowerRegistry[msg.sender];
        if (borrower.visited) {
            require(borrower.age == age, "Invalid Age");
            require(borrower.gender == gender, "Invalid Gender");
        } else {
            borrower.visited = true;
            borrower.age = age;
            borrower.gender = gender;
        }
        require(
            borrower.borrowedAnimal == AnimalType.None,
            "Already adopted a pet"
        );
        require(animalCounts[animal] > 0, "Selected animal not available");
        if (gender == Gender.Male) {
            require(
                animal == AnimalType.Dog || animal == AnimalType.Fish,
                "Invalid animal for men"
            );
        } else if (age < 40) {
            require(
                animal != AnimalType.Cat,
                "Invalid animal for women under 40"
            );
        }

        animalCounts[animal]--;
        borrower.borrowedAnimal = animal;

        emit Borrowed(animal);
    }

    function giveBackAnimal() public {
        Borrower storage borrower = borrowerRegistry[msg.sender];
        require(borrower.borrowedAnimal != AnimalType.None, "No borrowed pets");

        animalCounts[borrower.borrowedAnimal]++;
        borrower.borrowedAnimal = AnimalType.None;

        emit Returned(borrower.borrowedAnimal);
    }
}
