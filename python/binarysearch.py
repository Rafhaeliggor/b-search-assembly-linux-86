#binary search teste

def get_user_input():
    
    #Get the list
    numbers = []
    print("Enter numbers one by one (no data stops):")

    while True:
        user_input = input(">")
        if user_input == "":
            break
        try:
            num = int(user_input)
            numbers.append(num)
        except ValueError:
            print("Please enter a valid number or finish the process")
    return numbers

def bubble_sort(arr):
	n = len(arr)
	for i in range(n):
		for j in range(0, n-i-1):
			if arr[j] > arr[j+1]:
				arr[j], arr[j+1] = arr[j+1], arr[j]
	return arr

def binary_search(arr, target):
	left, right = 0, len(arr) - 1
	
	while left <= right:
		mid = (left + right) // 2
		print(f'left: {left}')
		print(f'right: {right}')
		print(f'mid: {mid}')
		print(f'mid number: {arr[mid]}')
		print('======================')
		if arr[mid] == target:
			return mid
		elif arr[mid] < target:
			left = mid + 1
		else:
			right = mid - 1

	return -1

def main ():

	answer = get_user_input()
	print(f'answer: {answer}')
	print(f'organized: {bubble_sort(answer)}')
	while True:
		target = int(input('Define the target: '))
		print(f'sorted: {binary_search(bubble_sort(answer), target)}')
		if target == "":
			break

if __name__ == "__main__":
    main()
